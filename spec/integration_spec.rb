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
  let(:collection)  { model.all(:rank.gte => 5, :closed_at.gt => 1.day.from_now, :closed_at.lt => 3.days.from_now, :comments => { :body => /aa/im }) }

  before { model.all.destroy }
  before { Comment.all.destroy }

  its(:size) { should eq(0) }

  context "when resource in scope is saved" do
    before do
      resource  = model.create! rank: 5, closed_at: 2.day.from_now
      resource.comments.create body: "AA"
    end

    its(:size)  { should eq(1) }
    its(:count) { should eq(1) }
  end

  context "when resource out of scope is saved" do
    before { model.create rank: 4 }

    its(:size) { should eq(0) }
    its(:count) { should eq(0) }
  end
end

describe User do
  subject { user }

  before do
    repository :master do
      model.all.destroy
    end
  end

  let(:model)     { described_class }
  let(:username)  { "testuser0" }
  let(:password)  { "abcdefgh" }
  let(:user)      { model.new username: username, password: password }

  it { should be_valid }

  context "when a vaid email is given" do
    let(:user) { model.new username: username, password: password, email: "#{username}@abc.com" }

    it { should be_valid }
  end

  context "when an invalid email is given" do
    let(:user) { model.new username: username, password: password, email: "dafdjlfdsaj" }

    it { should_not be_valid }
  end

  describe "class" do
    subject { model }

    let(:user) { model.create! username: username, password: password }

    its(:storage_name) { should eq("_User") }

    describe "#authenticate" do
      subject { model.authenticate username, password }

      it { should eq(user) }
    end
  end
end

describe "adapter" do
  subject { adapter }

  let(:adapter) { DataMapper::Repository.adapters[:default] }

  describe "#upload_file" do
    subject { adapter.upload_file filename, content }

    let(:filename)  { "xf x.txt" }
    let(:content)   { "xx" }

    it { should be_has_key("name") }
    it { should be_has_key("url") }
  end
end
