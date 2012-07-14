require "spec_helper"

describe DataMapper::Property::ParseFile do
  subject { property }

  let(:property)  { Article.properties[:attachment] }
  let(:url)       { "http://files.parse.com/3f10b6f9-bec4-4583-b907-8f2ece6e965a/003ce5ad-06c4-4be6-9475-b074b6bd4dc8-test.png" }
  let(:name)      { File.basename URI(url).path }

  describe "#typecast" do
    subject { property.typecast value }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end

    context "when value is io" do
      let(:value) { StringIO.new "xx" }
      
      before { value.stub(original_filename: "test.png", content_type: "image/png") }
      before { DataMapper::Adapters::ParseAdapter.any_instance.stub(upload_file: { "name" => name, "url" => url }) }

      it { should eq(URI(url)) }
    end

    context "when value is string" do
      let(:value) { url }

      it { should eq(URI(url)) }
    end
  end

  describe "#dump" do
    subject { property.dump value }

    let(:value) { URI(url) }

    it { should eq("__type" => "File", "name" => name, "url" => value.to_s) }
  end

  describe "#load" do
    subject { property.load value }

    let(:value) { { "__type" => "File", "name" => name, "url" => url } }

    it { should eq(URI(url)) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#valid?" do
    subject { property.valid? value }

    let(:value) { URI(url) }

    it { should be_true }
  end
end
