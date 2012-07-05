$: << File.join(File.dirname(__FILE__), "parse")
require "engine"
require "query"

module DataMapper
  module Adapters

    class ParseAdapter < AbstractAdapter
      include Parse::Conditions
      include Query::Conditions

      attr_reader :engine

      def initialize(name, options)
        super
        master = @options[:master].nil? ? false : @options[:master]
        @engine = Parse::Engine.new @options[:app_id], @options[:api_key], master
      end

      def create(resources)
        resources.each do |resource|
          params        = attributes_as_fields(resource.attributes(:property)).except("objectId", "createdAt", "updatedAt")
          model         = resource.model
          storage_name  = model.storage_name
          result        = engine.create storage_name, params

          initialize_serial resource, result["objectId"]
          resource.created_at = resource.updated_at = result["createdAt"]
        end.size
      end

      def read(query)
        model         = query.model
        params        = parse_params_for(query)
        storage_name  = model.storage_name
        response      = engine.read storage_name, params

        response["results"]
      rescue NotImplementedError
        log :error, "Unsupported Query:"
        log :error, "  Model: #{model}"
        log :error, "  Conditions: #{query.conditions}"

        raise NotImplementedError
      end

      # Read the "count" from Parse
      # This is Parse-only
      #
      # @param [Query] query
      #   the query to match resources in the datastore
      #
      # @return [Integer]
      #   the number of records that match the query
      #
      # @api semipublic
      def read_count(query)
        model           = query.model
        params          = parse_params_for(query)
        params[:count]  = 1
        params[:limit]  = 0
        storage_name    = model.storage_name
        response        = engine.read storage_name, params

        response["count"]
      end

      # Login, which is Parse-only
      #
      # @param [String] username
      #   the username
      # @param [String] password
      #   the password
      #
      # @return [Hash]
      #   the user information
      #
      # @api semipublic
      def sign_in(username, password)
        engine.sign_in username, password
      end

      # Request a password reset email
      # Parse-only
      #
      # @param [String] email
      #   the email address
      #
      # @return [Hash]
      #   a empty Hash
      def request_password_reset(email)
        engine.request_password_reset email
      end

      # Upload a file
      # Parse-only
      #
      # @param [String] filename
      #   the filename
      #
      # @param [String] content
      #   the content
      #
      # @param [String] content_type
      #   the content type
      #
      # @return [Hash]
      #   the uploaded file information
      def upload_file(filename, content, content_type)
        engine.upload_file filename, content, content_type
      end

      def delete(resources)
        resources.each do |resource|
          storage_name = resource.model.storage_name

          engine.delete storage_name, resource.id
        end.size
      end

      def update(attributes, resources)
        resources.each do |resource|
          params        = attributes_as_fields(attributes).except("createdAt", "updatedAt")
          storage_name  = resource.model.storage_name

          engine.update storage_name, resource.id, params
        end.size
      end

      private
      def parse_params_for(query)
        result = { :limit => parse_limit_for(query) }
        if conditions = parse_conditions_for(query)
          result[:where] = conditions.to_json
        end
        if (offset = parse_offset_for(query)) > 0
          result[:skip] = offset
        end
        if orders = parse_orders_for(query)
          result[:order] = orders
        end
        result
      end

      def parse_orders_for(query)
        orders = query.order
        return nil unless orders

        # cannot use objectId as order field on Parse
        orders = orders.reject { |order| order.target.field == "objectId" }.map do |order|
          field = order.target.field
          order.operator == :desc ? "-" + field : field
        end.join(",")

        orders.blank? ? nil : orders
      end

      def parse_offset_for(query)
        query.offset
      end

      def parse_limit_for(query)
        limit = query.limit || 1000
        raise "Parse limit: only number from 0 to 1000 is valid" unless (0..1000).include?(limit)
        limit 
      end

      def parse_conditions_for(query)
        conditions  = query.conditions
        return nil if conditions.blank?

        result = {}
        translate(conditions, result)
        result_for_parse = finalize result

        log :info, "Translating query on #{query.model}:"
        log :info, "  from: #{query.conditions}"
        log :info, "  to: #{result_for_parse.to_json}"

        result_for_parse
      end

      def translate(condition, result)
        case condition
        when RegexpComparison
          translate_for(result, condition, Regex)
        when EqualToComparison
          translate_for(result, condition, Eql)
        when GreaterThanComparison
          translate_for(result, condition, Gt)
        when GreaterThanOrEqualToComparison
          translate_for(result, condition, Gte)
        when LessThanComparison
          translate_for(result, condition, Lt)
        when LessThanOrEqualToComparison
          translate_for(result, condition, Lte)
        when InclusionComparison
          translate_for(result, condition, In)
        when NotOperation
          condition.each { |c| translate_reversely c, result }
        when AndOperation
          condition.each { |c| translate c, result }
        when OrOperation
          result["$or"] ||= []
          result["$or"] = result["$or"] + condition.map do |c|
            r = {}
            translate c, r
            r
          end
        else
          raise NotImplementedError
        end
      end

      def translate_reversely(condition, result)
        case condition
        when EqualToComparison
          translate_for(result, condition, Ne)
        when GreaterThanComparison
          translate_for(result, condition, Lte)
        when GreaterThanOrEqualToComparison
          translate_for(result, condition, Lt)
        when LessThanComparison
          translate_for(result, condition, Gte)
        when LessThanOrEqualToComparison
          translate_for(result, condition, Gt)
        when InclusionComparison
          translate_for(result, condition, Nin)
        when NotOperation
          condition.each { |c| translate c, result }
        when AndOperation
          condition.each { |c| translate_reversely c, result }
        else
          raise NotImplementedError
        end
      end

      def translate_for(result, condition, comparison_class)
        subject = condition.subject

        case subject
        when DataMapper::Property
          field = subject.field
          result[field] ||= []
          result[field] << comparison_class.new(condition.value)
        when DataMapper::Associations::OneToMany::Relationship
          child_key = condition.subject.child_key.first
          result["objectId"] ||= []
          result["objectId"] << comparison_class.new(condition.value.map { |resource| resource.send child_key.name })
        when DataMapper::Associations::ManyToOne::Relationship
          child_key = subject.child_key.first
          field     = child_key.field
          result[field] ||= []
          result[field] << comparison_class.new(condition.foreign_key_mapping.value)
        else
          raise NotImplementedError, "Condition: #{condition}"
        end
      end

      def finalize(queries)
        queries.inject({}) do |result, (field, comparisons)|
          if field == "$or"
            result.merge! field => comparisons.map { |c| finalize c }
          else
            result.merge! field => combine(comparisons)
          end
        end
      end

      def combine(comparisons)
        groups = comparisons.group_by { |comparison| comparison.is_a? Eql }
        equals = groups[true]
        others = groups[false]

        if equals.present? && others.present?
          raise "Parse Query: cannot combine Eql with others"
        elsif equals.present?
          raise "can only use one EqualToComparison for a field" unless equals.size == 1
          equals.first.as_json
        elsif others.present?
          others.inject({}) do |result, comparison|
            result.merge! comparison.as_json
          end
        end
      end

      def log(level, message)
        DataMapper.logger.send level, "[dm-parse][#{level}] #{message}"
      end

    end

    const_added(:ParseAdapter)
  end
end
