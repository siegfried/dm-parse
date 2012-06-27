module DataMapper
  module Is

    module Parse
      def is_parse(options = {})
        property :id, Property::ParseKey
        property :created_at, Property::ParseDate, field: "createdAt"
        property :updated_at, Property::ParseDate, field: "updatedAt"
      end

      def is_parse_user(options = {})
        is_parse(options)

        storage_names[:default] = "_User"

        property :username, Property::String
        property :password, Property::String

        class << self
          def authenticate(username, password)
            result = repository.adapter.sign_in(username, password)
            get(result["objectId"])
          end
        end
      end
    end

  end

  Model.append_extensions(Is::Parse)
end
