require "spec_helper"

describe "resource" do
  subject { resource }

  let(:resource)  { Article.new title: "Test Title", rank: 3, body: "Test Body" }

  before { Article.all.destroy }
  before { Comment.all.destroy }

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

  context "when resource is a child" do
    let(:resource)  { Comment.create article: parent }
    let(:parent)    { Article.create }

    its(:article) { should be(parent) }
  end
end

describe "collection" do
  subject { collection }

  let(:collection)  { Article.all(:rank.gte => 5, :closed_at.gt => 1.day.from_now, :closed_at.lt => 3.days.from_now, :comments => { :body => /aa/im }) }

  before { Article.all.destroy }
  before { Comment.all.destroy }

  its(:size) { should eq(0) }

  context "when resource in scope is saved" do
    before do
      resource = Article.create rank: 5, closed_at: 2.day.from_now
      resource.comments.create body: "AA"
    end

    its(:size)  { should eq(1) }
    its(:count) { should eq(1) }
  end

  context "when resource out of scope is saved" do
    before { Article.create rank: 4 }

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
    subject { adapter.upload_file filename, content, content_type }

    let(:filename)      { "xf x.txt" }
    let(:content)       { "xx" }
    let(:content_type)  { "plain/txt" }

    it { should be_has_key("name") }
    it { should be_has_key("url") }
  end

  describe "#request_password_reset" do
    subject { adapter.request_password_reset email }

    before do
      repository :master do
        User.all.destroy
      end
    end

    let(:email) { user.email }
    let(:user)  { User.create! username: "a", password: "a", email: "a@abc.cn" }

    it { should eq({}) }
  end
end
