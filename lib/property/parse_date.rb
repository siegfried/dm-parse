module DataMapper
  class Property

    class ParseDate < Object

      def dump(value)
        case value
        when ::Date
          {"__type" => "Date", "iso" => value.to_datetime.utc.iso8601(3)}
        when ::DateTime
          {"__type" => "Date", "iso" => value.utc.iso8601(3)}
        when ::Hash
          value
        end
      end

      def load(value)
        typecast(value)
      end

      def typecast(value)
        case value
        when ::Hash
          value["iso"].to_datetime
        when ::NilClass
          value
        else
          value.to_datetime
        end
      end

    end

  end
end
