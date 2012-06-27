require "spec_helper"

describe DataMapper::Property::ParseDate do
  subject { property }
  let(:property) { Article.properties[:created_at] }
  let(:datetime) { DateTime.parse("2011-08-21T18:02:52.249Z") }

  describe "#dump" do
    subject { property.dump value }
    let(:value) { datetime }

    it { should eq("__type" => "Date", "iso" => datetime.utc.iso8601(3)) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#load" do
    subject { property.load value }
    let(:value) { {"__type" => "Date", "iso" => datetime.utc.iso8601(3)} }

    it { should eq(datetime) }

    context "when value is in string" do
      let(:value) { "2011-08-21T18:02:52.249Z" }

      it { should eq(datetime) }
    end

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#valid?" do
    subject { property.valid? datetime }

    it { should be_true }
  end
end
