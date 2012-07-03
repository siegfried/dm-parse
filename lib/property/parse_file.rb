module DataMapper
  class Property

    class ParseFile < Object

      def dump(value)
        value && { "__type" => "File", "name" => File.basename(value.path) }
      end

      def load(value)
        value && URI(value["url"])
      end

      def typecast(value)
        if value.respond_to?(:original_filename) && value.respond_to?(:read) && value.respond_to?(:content_type)
          adapter       = model.repository.adapter
          filename      = value.original_filename
          content       = value.read
          content_type  = value.content_type
          response      = adapter.upload_file(filename, content, content_type)
          URI(response["url"])
        end
      end

    end

  end
end
