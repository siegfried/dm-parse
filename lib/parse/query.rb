module DataMapper
  module Parse

    module Conditions
      class Comparison
        def initialize(value)
          @value = value
        end

        def build
          { key_name => @value }
        end

        def key_name
          "$#{self.class.to_s.demodulize.downcase}"
        end
      end

      class Eql < Comparison
        def build
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
          @value = value.to_a
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

        def build
          {key_name => @value.source}.tap { |value| value["$options"] = options if options.present? }
        end
      end

      class Query
        def initialize
          @conditions = Mash.new
        end

        def add(field, comparison)
          @conditions[field] ||= []
          @conditions[field] << comparison
          self
        end

        def combine(comparisons)
          groups = comparisons.group_by { |comparison| comparison.is_a? Eql }
          equals = groups[true]
          others = groups[false]

          if equals.present? && others.present?
            raise "Parse Query: cannot combine Eql with others"
          elsif equals.present?
            raise "can only use one EqualToComparison for a field" unless equals.size == 1
            equals.first.build
          elsif others.present?
            others.inject({}) do |result, comparison|
              result.merge! comparison.build
            end
          end
        end

        def build
          @conditions.inject({}) do |result, (field, comparisons)|
            result.merge! field => combine(comparisons)
          end
        end
      end

      class Or
        def initialize
          @queries = []
        end

        def add(query)
          @queries << query
        end

        def build
          {"$or" => @queries.map { |query| query.build } }
        end
      end

    end
  end
end
