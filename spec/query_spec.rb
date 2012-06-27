require "spec_helper"

describe DataMapper::Parse::Conditions::Regex do
  let(:regex) { described_class.new value }

  describe "#options" do
    subject { regex.options }

    context "when case insensitive option is on" do
      let(:value) { /bbq/i }
      it { should eq("i") }
    end

    context "when multiline option is on" do
      let(:value) { /bbq/m }
      it { should eq("m") }
    end

    context "when both case insensitive and multiline option is on" do
      let(:value) { /bbq/mi }
      it { should eq("im") }
    end
  end # #regex_options

end
