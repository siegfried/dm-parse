module DataMapper
  class Property

    class ParseKey < Object
      def serial?
        true
      end

      key     true
      field   "objectId"

      def load(value)
        value.to_s
      end

      def dump(value)
        value && value.to_s
      end

      def to_child_key
        Property::ParsePointer
      end
    end

  end
end
