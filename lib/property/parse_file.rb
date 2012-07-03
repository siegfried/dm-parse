module DataMapper
  class Property

    class ParseFile < Object

      def dump(value)
        value
      end

      def load(value)
        value
      end

      def typecast(value)
        if value.respond_to?(:original_filename) && value.respond_to?(:read) && value.respond_to?(:content_type)
          adapter       = model.repository.adapter
          filename      = value.original_filename
          content       = value.read
          content_type  = value.content_type
          adapter.upload_file(filename, content, content_type).merge("__type" => "File")
        else
          value
        end
      end

    end

  end
end
