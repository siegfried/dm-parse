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

        property :username, Property::String, unique: true
        property :password, Property::String
        property :email,    Property::String, format: :email_address

        class << self
          # Authenticate a user
          #
          # @param [String] username
          #   username
          #
          # @param [String] password
          #   password
          #
          # @return [Resource, nil]
          #   the user resource, or nil if authentication failed
          #
          # @api semipublic
          def authenticate(username, password)
            result = repository.adapter.sign_in(username, password)
            get(result["objectId"])
          rescue ::Parse::ParseError
            nil
          end

          def request_password_reset(email)
            repository.adapter.request_password_reset email
          end
        end
      end
    end

  end

  Model.append_extensions(Is::Parse)
end
