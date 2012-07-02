module DataMapper

  module ::Parse
    module Protocol
      HEADER_MASTER_KEY = "X-Parse-Master-Key"
    end

    class Client
      def initialize(data = {})
        @host     = data[:host] || Protocol::HOST
        @app_id   = data[:app_id]
        @api_key  = data[:api_key]
        @session  = Patron::Session.new
        @session.timeout = 10
        @session.connect_timeout = 10

        @session.base_url                 = "https://#{host}"
        @session.headers["Content-Type"]  = "application/json"
        @session.headers["Accept"]        = "application/json"
        @session.headers["User-Agent"]    = "Parse for Ruby, 0.0"
        @session.headers[Protocol::HEADER_APP_ID] = @app_id

        key_type = data[:master] ? Protocol::HEADER_MASTER_KEY : Protocol::HEADER_API_KEY
        @session.headers[key_type] = @api_key
      end
    end
  end

  module Parse

    class Engine

      attr_reader :client

      def initialize(app_id, api_key, master)
        @client = ::Parse::Client.new app_id: app_id, api_key: api_key, master: master
      end

      def read(storage_name, params)
        query = params.inject({}) do |result, (k, v)|
          result.merge k.to_s => CGI.escape(v.to_s)
        end
        client.request uri_for(storage_name), :get, nil, query
      end

      def delete(storage_name, id)
        client.delete uri_for(storage_name, id)
      end

      def create(storage_name, attributes)
        client.post uri_for(storage_name), attributes.to_json
      end

      def update(storage_name, id, attributes)
        client.put uri_for(storage_name, id), attributes.to_json
      end

      def sign_in(username, password)
        client.request ::Parse::Protocol::USER_LOGIN_URI, :get, nil, { username: username, password: password }
      end

      def upload_file(filename, content, content_type)
        client.post ::Parse::Protocol.file_uri(URI.escape(filename)), content
      end

      def request_password_reset(email)
        client.post ::Parse::Protocol::PASSWORD_RESET_URI, {email: email}.to_json
      end

      private

      def uri_for(storage_name, id = nil)
        storage_name == "_User" ? ::Parse::Protocol.user_uri(id) : ::Parse::Protocol.class_uri(storage_name, id)
      end

    end

  end
end
