require "spec_helper"

describe "resource" do
  subject { resource }

  let(:resource)  { model.new title: "Test Title", rank: 3, body: "Test Body" }
  let(:model)     { Article }

  before { model.all.destroy }

  it { should be_new }
  it { should be_dirty }
  its(:id)          { should be_nil }
  its(:created_at)  { should be_nil }
  its(:updated_at)  { should be_nil }

  context "after save" do
    before { resource.save }

    it { should_not be_nil }
    it { should_not be_dirty }
    its(:id)          { should_not be_nil }
    its(:created_at)  { should_not be_nil }
    its(:updated_at)  { should_not be_nil }
  end
end

describe "collection" do
  subject { collection }

  let(:model)       { Article }
  let(:collection)  { model.all(:rank.gte => 5) }

  before { model.all.destroy }

  its(:size) { should eq(0) }

  context "when resource in scope is saved" do
    before { model.create rank: 5 }

    its(:size) { should eq(1) }
  end

  context "when resource out of scope is saved" do
    before { model.create rank: 4 }

    its(:size) { should eq(0) }
  end
end
