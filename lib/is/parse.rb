module DataMapper
  module Is
    module Parse
      def is_parse(options = {})
        property :id, Property::ParseKey
      end
    end
  end

  Model.append_extensions(Is::Parse)
end
