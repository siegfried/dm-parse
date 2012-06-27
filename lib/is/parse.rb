module DataMapper
  module Is
    module Parse
      def is_parse(options = {})
        property :id, Property::ParseKey
        property :created_at, Property::ParseDate, field: "createdAt"
        property :updated_at, Property::ParseDate, field: "updatedAt"
      end
    end
  end

  Model.append_extensions(Is::Parse)
end
