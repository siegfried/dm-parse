module DataMapper
  module Parse

    module Conditions
      class Comparison
        def initialize(value)
          @value = value
        end

        def as_json
          { key_name => @value }
        end

        def key_name
          "$#{self.class.to_s.demodulize.downcase}"
        end
      end

      class Eql < Comparison
        def as_json
          @value
        end
      end

      class Ne < Comparison
      end

      class Lt < Comparison
      end

      class Lte < Comparison
      end

      class Gt < Comparison
      end

      class Gte < Comparison
      end

      class InComparison < Comparison
        def initialize(value)
          @value = value.is_a?(Hash) ? [value] : value.to_a
        end
      end

      class In < InComparison
      end

      class Nin < InComparison
      end

      class Regex < Comparison
        def options
          options = @value.options
          result = []
          result << "i" if options[0] == 1
          result << "m" if options[2] == 1
          result.join
        end

        def as_json
          { key_name => @value.source }.tap { |value| value["$options"] = options if options.present? }
        end
      end

    end
  end
end
