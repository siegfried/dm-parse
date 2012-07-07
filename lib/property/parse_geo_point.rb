module DataMapper
  class Property

    class ParseGeoPoint < Object

      def dump(value)
        value && {"__type" => "GeoPoint", "latitude" => value["lat"].to_f, "longitude" => value["lng"].to_f}
      end

      def load(value)
        value && {"lat" => value["latitude"], "lng" => value["longitude"]}
      end

      def typecast(value)
        case value
        when ::Hash
          lat = value["lat"]
          lng = value["lng"]
          { "lat" => lat, "lng" => lng } if lat.present? && lng.present?
        end
      end

      def valid?(value)
        return false if value && (value["lat"].blank? || value["lng"].blank?)
        super
      end
    end

  end
end
