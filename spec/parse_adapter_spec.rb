require "spec_helper"

describe DataMapper::Adapters::ParseAdapter do
  let(:adapter)           { DataMapper.setup(:default, options) }
  let(:options)           { { adapter: :parse, app_id: app_id, api_key: api_key } }
  let(:app_id)            { "xxx" }
  let(:api_key)           { "yyy" }
  let(:app_id_header)     { "X-Parse-Application-Id" }
  let(:api_key_header)    { "X-Parse-REST-API-Key" }
  let(:master_key_header) { "X-Parse-Master-Key" }
  let(:model)             { Article }

  describe "#parse_conditions_for" do
    subject { adapter.send :parse_conditions_for, query }

    context "when query is nil" do
      let(:query) { model.all.query }
      it { should be_nil }
    end

    context "when query assigns some exact values" do
      let(:query) { model.all(:id => "z", :title => "x", :body => "y").query }

      it { should eq("objectId" => "z", "title" => "x", "body" => "y") }

      it "should log translation info" do
        DataMapper.logger.should_receive(:info).with(an_instance_of(String)).exactly(3).times
        adapter.send :parse_conditions_for, query
      end
    end

    [:gt, :gte, :lt, :lte].each do |slug|
      context "when query has #{slug} comparison" do
        let(:query) { model.all(:id => "z", :rank.send(slug) => 5).query }
        it { should eq("objectId" => "z", "rank" => {"$#{slug}" => 5}) }
      end
    end

    context "when query has :not operation" do
      let(:query) { model.all(:rank.not => 5, :body.not => "x").query }
      it { should eq("rank" => {"$ne" => 5}, "body" => {"$ne" => "x"}) }
    end
    
    context "when query has multiple comparisons of one field" do
      let(:query) { model.all(:rank.lt => 5, :rank.gt => 3).query }
      it { should eq("rank" => {"$lt" => 5, "$gt" => 3}) }
    end

    context "when query has :in comparison" do
      let(:query) { model.all("rank" => 1..3).query }
      it { should eq("rank" => {"$in" => (1..3).to_a}) }
    end

    context "when query has :regexp comparison" do
      let(:query) { model.all(:body => regex).query }
      let(:regex) { /^[A-Z]\d/ }

      it { should eq("body" => {"$regex" => "^[A-Z]\\d"}) }

      context "when regular expersion has options" do
        let(:regex) { /bbq/mi }

        it { should eq("body" => {"$regex"=>"bbq", "$options"=>"im"}) }
      end
    end

    context "when query has :or operation" do
      let(:query) { (model.all(:rank => 3) + model.all(:rank => 4) + model.all(:rank => 5)).query }
      it { should eq("$or" => [{"rank" => 3}, {"rank" => 4}, {"rank" => 5}]) }

      context "in :and operation" do
        let(:query) { (model.all(:title => "x") & (model.all(:rank => 3) + model.all(:rank => 4))).query }
        it { should eq("title" => "x", "$or" => [{"rank" => 3}, {"rank" => 4}]) }
      end
    end

    context "when query has union operator" do
      let(:query) { (model.all(:rank => 3) | model.all(:rank => 4) | model.all(:rank => 5)).query }
      it { should eq("$or" => [{"rank" => 3}, {"rank" => 4}, {"rank" => 5}]) }
    end

    context "when query has and operator" do
      let(:query) { (model.all("rank" => 5) & model.all("body" => "x")).query }
      it { should eq("rank" => 5, "body" => "x") }
    end

    context "when query has complex :not operation" do
      let(:query) { (model.all - model.all(:rank => 5, :body => "x")).query }
      it { should eq("rank" => {"$ne" => 5}, "body" => {"$ne" => "x"}) }

      context "when condition is not EqualToComparison" do
        let(:query) { model.all(:rank.not => [2, 3]).query }
        it { should eq("rank" => {"$nin" => [2, 3]}) }
      end
    end

    describe "exceptions" do
      subject { -> { adapter.send :parse_conditions_for, query } }

      context "when the key is same" do
        let(:query) { (model.all("rank" => 5) & model.all("rank" => 3)).query }
        it { should raise_error("can only use one EqualToComparison for a field") }
      end

      context "when query has :eql and others of one field" do
        let(:query) { model.all(:rank => 5, :rank.gt => 3).query }
        it { should raise_error }
      end
    end # exceptions
  end # #parse_conditions_for

  describe "#parse_orders_for" do
    subject { adapter.send :parse_orders_for, query }
    let(:query) { model.all("body" => "x").query }
    it { should be_nil }

    context "when orders are given" do
      let(:query) { model.all(:order => [:rank.asc, :title.desc]).query }
      it { should eq("rank,-title") }
    end
  end # #parse_orders_for

  describe "#parse_limit_for" do
    subject { adapter.send :parse_limit_for, query }
    let(:query) { model.all.query }
    it { should eq(1000) }

    context "when 0 is given" do
      let(:query) { model.all(:limit => 0).query }
      it { should eq(0) }
    end

    describe "exceptions" do
      subject { -> { adapter.send :parse_limit_for, query } }

      context "when 1001 is given" do
        let(:query) { model.all(:limit => 1001).query }
        it { should raise_error("Parse limit: only number from 0 to 1000 is valid") }
      end
    end
  end # #parse_limit_for

  describe "#parse_offset_for" do
    subject { adapter.send :parse_offset_for, query }
    let(:query) { model.all.query }
    it { should eq(0) }

    context "when a number is given" do
      let(:query) { model.all(:offset => number, :limit => 200).query }

      context "the number is positive" do
        let(:number) { 1 }
        it { should eq(number) }
      end

      context "the number is positive" do
        let(:number) { 0 }
        it { should eq(number) }
      end
    end

    describe "exceptions" do
      subject { -> { adapter.send :parse_offset_for, query } }
      let(:query) { model.all(:offset => number, :limit => 200).query }

      context "the number is negative" do
        let(:number) { -1 }
        it { should raise_error }
      end
    end
  end # #parse_offset_for

  describe "#parse_params_for" do
    subject { adapter.send :parse_params_for, query }
    let(:query) { model.all.query }

    it { should eq(:limit => 1000) }

    context "when limit is given" do
      let(:query) { model.all(:limit => 200).query }
      it { should eq(:limit => 200) }
    end

    context "when conditions is given" do
      let(:query) { model.all(:rank => 5).query }
      it { should eq(:limit => 1000, :where => {"rank" => 5}.to_json) }
    end

    context "when offset is given" do
      let(:query) { model.all(:limit => 200, :offset => 300).query }
      it { should eq(:limit => 200, :skip => 300) }
    end

    context "when orders are given" do
      let(:query) { model.all(:order => [:rank.desc]).query }
      it { should eq(:limit => 1000, :order => "-rank") }
    end
  end # #parse_params_for

end
