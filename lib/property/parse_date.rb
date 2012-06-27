module DataMapper
  class Property

    class ParseDate < Object

      def dump(value)
        value && {"__type" => "Date", "iso" => value.to_datetime.utc.iso8601(3)}
      end

      def load(value)
        value && (value.is_a?(Hash) ? value["iso"].to_datetime : value.to_datetime)
      end

    end

  end
end
