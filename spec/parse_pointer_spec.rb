require "spec_helper"

describe DataMapper::Property::ParsePointer do
  subject { pointer }
  let(:pointer) { Comment.properties[:article_id] }

  describe "#dump" do
    subject { pointer.dump value }
    let(:value) { "xxx" }

    it { should eq("__type" => "Pointer", "className" => Article.storage_name, "objectId" => "xxx") }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#load" do
    subject { pointer.load value }
    let(:value) { {"__type" => "Pointer", "className" => Article.storage_name, "objectId" => "xxx"} }

    it { should eq("xxx") }
  end

  describe "#valid?" do
    subject { pointer.valid? "xxx" }

    it { should be_true }
  end
end
