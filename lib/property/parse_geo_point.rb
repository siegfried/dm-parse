module DataMapper
  class Property

    class ParseGeoPoint < Object

      def dump(value)
        value && {"__type" => "GeoPoint", "latitude" => value["lat"].to_f, "longitude" => value["lng"].to_f}
      end

      def load(value)
        value && {"lat" => value["latitude"], "lng" => value["longitude"]}
      end

      def valid?(value)
        return false if value && (value["lat"].nil? || value["lng"].nil?)
        super
      end
    end

  end
end
