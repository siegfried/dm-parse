module DataMapper
  class Property

    class ParseKey < String
      def serial?
        true
      end

      key     true
      field   "objectId"
      length  255

      def to_child_key
        Property::String
      end
    end

  end
end
