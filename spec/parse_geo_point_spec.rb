require "spec_helper"

describe DataMapper::Property::ParseGeoPoint do
  subject { property }

  let(:property) { User.properties[:location] }

  describe "#dump" do
    subject { property.dump value }

    let(:value) { { "latitude" => 20.0, "longitude" => 50.0 } }

    it { should eq("__type" => "GeoPoint", "latitude" => 20.0, "longitude" => 50.0) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#load" do
    subject { property.load value }

    let(:value) { { "__type" => "GeoPoint", "latitude" => 20.0, "longitude" => 50.0 } }

    it { should eq(value) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#valid?" do
    subject { property.valid? value }

    let(:value) { { "latitude" => lat, "longitude" => lng } }
    let(:lat)   { "20.0" }
    let(:lng)   { "50.0" }

    it { should be_true }

    context "when latitude is nil" do
      let(:lat) { nil }

      it { should be_false }
    end

    context "when latitude is empty string" do
      let(:lat) { "" }

      it { should be_false }
    end

    context "when longitude is nil" do
      let(:lng) { nil }

      it { should be_false }
    end

    context "when longitude is empty string" do
      let(:lng) { "" }

      it { should be_false }
    end

    context "when value is nil" do
      let(:value) { nil }

      it { should be_true }
    end
  end

  describe "#typecast" do
    subject { property.typecast value }

    let(:value) { { "latitude" => lat, "longitude" => lng } }
    let(:lat)   { "20.0" }
    let(:lng)   { "50.0" }

    it { should eq("latitude" => lat.to_f, "longitude" => lng.to_f) }

    context "when latitude is nil" do
      let(:lat) { nil }

      it { should be_blank }
    end

    context "when latitude is empty string" do
      let(:lat) { "" }

      it { should be_blank }
    end

    context "when longitude is nil" do
      let(:lng) { nil }

      it { should be_blank }
    end

    context "when longitude is empty string" do
      let(:lng) { "" }

      it { should be_blank }
    end
  end
end
