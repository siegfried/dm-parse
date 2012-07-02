module DataMapper
  class Property

    class ParseFile < Object

      def dump(value)
        if value.is_a?(Hash)
          value.merge("__type" => "File")
        elsif value.respond_to?(:original_filename) && value.respond_to?(:read) && value.respond_to?(:content_type)
          adapter       = model.repository.adapter
          filename      = value.original_filename
          content       = value.read
          content_type  = value.content_type
          dump adapter.upload_file(filename, content, content_type)
        else
          nil
        end
      end

      def load(value)
        value
      end

    end

  end
end
