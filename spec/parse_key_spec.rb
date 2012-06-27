require "spec_helper"

describe DataMapper::Property::ParseKey do
  subject { property }
  let(:property) { Article.properties[:id] }

  describe "#dump" do
    subject { property.dump value }
    let(:value) { "xxx" }

    it { should eq("xxx") }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#load" do
    subject { property.load value }
    let(:value) { "xxx" }

    it { should eq("xxx") }
  end

  describe "#valid?" do
    subject { property.valid? "xxx" }

    it { should be_true }
  end
end
