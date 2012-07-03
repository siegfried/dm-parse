require "spec_helper"

describe DataMapper::Property::ParseFile do
  subject { property }

  let(:property) { Article.properties[:attachment] }

  describe "#typecast" do
    subject { property.typecast value }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end

    context "when value is io" do
      let(:value) { StringIO.new "xx" }
      
      before { value.stub(original_filename: "xx.txt", content_type: "plain/text") }
      before { DataMapper::Adapters::ParseAdapter.any_instance.stub(upload_file: {"name" => "x", "url" => "y"}) }

      it { should be_has_key("__type") }
      it { should be_has_key("name") }
      it { should be_has_key("url") }
    end
  end

  describe "#load" do
    subject { property.load value }

    let(:value) { { "__type" => "File", "name" => "a.png", "url" => "http://a.cn/a.png" } }

    it { should eq(value) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#valid?" do
    subject { property.valid? value }

    let(:value) { { "__type" => "File", "name" => "a.png", "url" => "http://a.cn/a.png" } }

    it { should be_true }
  end
end
