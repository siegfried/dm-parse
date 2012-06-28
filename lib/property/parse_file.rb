module DataMapper
  class Property

    class ParseFile < Object

      def dump(value)
        value && {"__type" => "File", "name" => value.to_s}
      end

      def load(value)
        value && (value.is_a?(Hash) ? value["name"].to_s : value.to_s)
      end

    end

  end
end
