module DataMapper
  module Parse
    # Read the body to get detail of Parse error
    class Connection < ::Nestful::Connection
      def handle_response(response)
        response.read_body if (400...500).include? response.code.to_i
        super
      end
    end

    ::Nestful::Request.class_eval do
      def connection
        conn              = Connection.new(uri, format)
        conn.proxy        = proxy if proxy
        conn.user         = user if user
        conn.password     = password if password
        conn.auth_type    = auth_type if auth_type
        conn.timeout      = timeout if timeout
        conn.ssl_options  = ssl_options if ssl_options
        conn
      end
    end # This is a workaround. Mixin for Connection does not work somehow.

    module ParseError
      def to_s
        error = JSON.parse(response.body)["error"]
        super + "  Response Parse Error = #{error}"
      end
    end

    ::Nestful::BadRequest.send          :include, ParseError
    ::Nestful::UnauthorizedAccess.send  :include, ParseError
    ::Nestful::ForbiddenAccess.send     :include, ParseError
    ::Nestful::ResourceNotFound.send    :include, ParseError
    ::Nestful::MethodNotAllowed.send    :include, ParseError
    ::Nestful::ResourceConflict.send    :include, ParseError
    ::Nestful::ResourceGone.send        :include, ParseError
    ::Nestful::ResourceInvalid.send     :include, ParseError

    class Resource < ::Nestful::Resource
      attr_reader :options

      def ==(resource)
        url == resource.url && options == resource.options
      end

      def delete(options = {})
        Nestful.delete(url, options.merge(@options))
      end

      def put(options = {})
        Nestful.put(url, options.merge(@options))
      end
    end
  end
end
