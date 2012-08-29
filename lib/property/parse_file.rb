module DataMapper
  class Property

    class ParseFile < Object

      def dump(value)
        case value
        when ::URI
          { "__type" => "File", "name" => File.basename(value.path), "url" => value.to_s }
        when ::Hash
          value
        end
      end

      def load(value)
        value && URI(value["url"])
      end

      def typecast(value)
        if value.respond_to?(:original_filename) && value.respond_to?(:read) && value.respond_to?(:content_type)
          adapter       = model.repository.adapter
          filename      = Digest::SHA256.new.hexdigest value.original_filename
          content       = value.read
          content_type  = value.content_type
          response      = adapter.upload_file(filename, content, content_type)
          URI(response["url"])
        elsif value.is_a?(::Hash)
          URI(value["url"])
        elsif value.is_a?(::String)
          URI(value)
        end
      end

    end

  end
end
