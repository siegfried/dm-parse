module DataMapper
  class Property

    class ParsePointer < Object

      def dump(value)
        value && {"__type" => "Pointer", "className" => target_storage_name, "objectId" => value.to_s}
      end

      def load(value)
        value.is_a?(Hash) ? value["objectId"] : super
      end

      private
      def target_storage_name
        model.relationships.select { |r| r.child_key.include? self }.first.parent_model.storage_name
      end
    end

  end
end
