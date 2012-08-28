module DataMapper
  class Property

    class ParseGeoPoint < Object

      def dump(value)
        value && value.merge("__type" => "GeoPoint")
      end

      def load(value)
        value
      end

      def typecast(value)
        case value
        when ::Hash
          lat = value["latitude"]
          lng = value["longitude"]
          { "latitude" => lat.to_f, "longitude" => lng.to_f } if lat.present? && lng.present?
        end
      end

      def valid?(value)
        return false if value && (value["latitude"].blank? || value["longitude"].blank?)
        super
      end
    end

  end
end
