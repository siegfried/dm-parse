module DataMapper
  module Parse
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
