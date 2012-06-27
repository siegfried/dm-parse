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

  shared_examples_for DataMapper::Parse::Resource do
    let(:options) { { adapter: :parse, app_id: app_id, api_key: api_key} }

    it { should be_a(DataMapper::Parse::Resource) }
    its(:options) { should eq(format: :json, headers: {app_id_header => app_id, api_key_header => api_key}) }
    context "when master mode is on" do
      let(:options) { { adapter: :parse, app_id: app_id, api_key: api_key, master: true } }

      its(:options) { should eq(format: :json, headers: {app_id_header => app_id, master_key_header => api_key}) }
    end
  end

  describe "#classes" do
    subject { adapter.classes }
    its(:url) { should eq("https://api.parse.com/1/classes") }
    it_should_behave_like DataMapper::Parse::Resource
  end

  describe "#users" do
    subject { adapter.users }
    its(:url) { should eq("https://api.parse.com/1/users") }
    it_should_behave_like DataMapper::Parse::Resource
  end

  describe "#login" do
    subject { adapter.login }
    its(:url) { should eq("https://api.parse.com/1/login") }
    it_should_behave_like DataMapper::Parse::Resource
  end

  describe "#parse_resources_for" do
    subject { adapter.parse_resources_for model }
    it { should eq(adapter.classes[model.storage_name]) }
    
    context "when storage_name of model is _User" do
      before(:each) { model.stub(storage_name: "_User") }
      it { should eq(adapter.users) }
    end
  end

  describe "#parse_resource_for" do
    subject { adapter.parse_resource_for resource }
    let(:resource) { model.new id: "xxx" }
    it { should eq(adapter.parse_resources_for(model)["xxx"]) }
  end

  describe "#create" do
    subject { adapter.create resources }

    let(:resources)   { [resource] }
    let(:resource)    { model.new attributes }
    let(:attributes)  { { id: "fd", rank: 3, created_at: 1.day.ago, updated_at: 2.days.ago } }

    before(:each) do
      double_resources = double("resource")
      double_resources.should_receive(:post).with(params: {"rank" => 3}).once.and_return({"createdAt" => "2011-08-20T02:06:57.931Z", "objectId" => "Ed1nuqPvcm"})
      adapter.stub(parse_resources_for: double_resources)
    end

    it { should eq(1) }
  end

  describe "#read" do
    subject { adapter.read query }

    let(:query)   { model.all(:rank => 4).query }
    let(:results) { [{"objectId" => "anything"}] }

    before(:each) do
      double_resources = double("resource")
      double_resources.should_receive(:get).with(params: { limit: 1000, where: {"rank" => 4}.to_json }).once.and_return("results" => results)
      adapter.stub(parse_resources_for: double_resources)
    end

    it { should eq(results) }
  end

  describe "#delete" do
    subject { adapter.delete resources }

    let(:resources) { [resource] }
    let(:resource)  { model.new id: id }
    let(:id)        { "xxx" }

    before(:each) do
      double_resource = double("resource")
      double_resource.should_receive(:delete).with(no_args).once.and_return({})
      adapter.stub(parse_resource_for: double_resource)
    end

    it { should eq(1) }
  end

  describe "#update" do
    subject { adapter.update attributes, resources }

    let(:resources)   { [resource] }
    let(:resource)    { model.new id: "xxx" }
    let(:attributes)  { model.new(rank: 5, created_at: 1.day.ago, updated_at: 2.days.ago).attributes(:property) }

    before(:each) do
      double_resource = double("resource")
      double_resource.should_receive(:put).with(params: {"rank" => 5}).once.and_return("updatedAt" => "2011-08-21T18:02:52.248Z")
      adapter.stub(parse_resource_for: double_resource)
    end

    it { should eq(1) }
  end
end
