require "spec_helper"

describe DataMapper::Property::ParseGeoPoint do
  subject { property }

  let(:property) { User.properties[:location] }

  describe "#dump" do
    subject { property.dump value }

    let(:value) { { "lat" => "20", "lng" => "50" } }

    it { should eq("__type" => "GeoPoint", "latitude" => value["lat"].to_f, "longitude" => value["lng"].to_f) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#load" do
    subject { property.load value }

    let(:value) { { "__type" => "GeoPoint", "latitude" => 20.0, "longitude" => 50.0 } }

    it { should eq("lat" => value["latitude"], "lng" => value["longitude"]) }

    context "when value is nil" do
      let(:value) { nil }

      it { should be_nil }
    end
  end

  describe "#valid?" do
    subject { property.valid? value }

    let(:value) { { "lat" => lat, "lng" => lng } }
    let(:lat)   { "20.0" }
    let(:lng)   { "50.0" }

    it { should be_true }

    context "when lat is nil" do
      let(:lat) { nil }

      it { should be_false }
    end

    context "when lng is nil" do
      let(:lng) { nil }

      it { should be_false }
    end

    context "when value is nil" do
      let(:value) { nil }

      it { should be_true }
    end
  end
end
