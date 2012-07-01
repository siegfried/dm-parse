module DataMapper
  module Parse

    class Engine

      HOST              = "https://api.parse.com"
      VERSION           = "1"
      APP_ID_HEADER     = "X-Parse-Application-Id"
      API_KEY_HEADER    = "X-Parse-REST-API-Key"
      MASTER_KEY_HEADER = "X-Parse-Master-Key"

      attr_reader :classes, :users, :login, :password_reset, :file_storage

      def initialize(app_id, api_key, master)
        @app_id         = app_id
        @api_key        = api_key
        @master         = master
        @classes        = build_parse_resource_for "classes"
        @users          = build_parse_resource_for "users"
        @login          = build_parse_resource_for "login"
        @password_reset = build_parse_resource_for "requestPasswordReset"
        @file_storage   = build_parse_resource_for "files"
      end

      def read(storage_name, params)
        parse_resources_for(storage_name).get params: params
      end

      def delete(storage_name, id)
        parse_resources_for(storage_name)[id].delete
      end

      def create(storage_name, attributes)
        parse_resources_for(storage_name).post params: attributes
      end

      def update(storage_name, id, attributes)
        parse_resources_for(storage_name)[id].put params: attributes
      end

      def sign_in(username, password)
        login.get params: {username: username, password: password}
      end

      def upload_file(filename, content, content_type)
        storage = file_storage[URI.escape(filename)]
        storage.options[:headers]["Content-Type"] = content_type
        storage.post body: content
      end

      def request_password_reset(email)
        password_reset.post params: {email: email}
      end

      private

      def parse_resources_for(storage_name)
        storage_name == "_User" ? users : classes[storage_name]
      end

      def build_parse_resource_for(name)
        Parse::Resource.new(HOST, format: :json, headers: key_headers)[VERSION][name]
      end

      def key_headers
        key_type  = @master ? MASTER_KEY_HEADER : API_KEY_HEADER
        {
          APP_ID_HEADER => @app_id,
          key_type => @api_key
        }
      end

    end

  end
end
