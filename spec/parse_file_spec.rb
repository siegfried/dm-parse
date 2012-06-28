require "spec_helper"

describe DataMapper::Property::ParseFile do
  subject { property }

  let(:property) { Article.properties[:attachment] }

  describe "#dump" do
    subject { property.dump value }

    let(:value) { "http://a.cn/a.png" }

    it { should eq("__type" => "File", "name" => value) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#load" do
    subject { property.load value }

    let(:value) { { "__type" => "File", "name" => "http://a.cn/a.png" } }

    it { should eq(value["name"]) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#valid?" do
    subject { property.valid? value }

    let(:value) { "http://a.cn/a.png" }

    it { should be_true }
  end
end
