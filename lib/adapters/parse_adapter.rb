module DataMapper
  module Adapters

    class ParseAdapter < AbstractAdapter
      include Parse::Conditions
      include Query::Conditions

      HOST              = "https://api.parse.com"
      VERSION           = "1"
      APP_ID_HEADER     = "X-Parse-Application-Id"
      API_KEY_HEADER    = "X-Parse-REST-API-Key"
      MASTER_KEY_HEADER = "X-Parse-Master-Key"

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
          resource.created_at = resource.updated_at = result["createdAt"].to_datetime
        end.size
      end

      def read(query)
        model         = query.model
        params        = parse_params_for(query)
        storage_name  = model.storage_name
        response      = engine.read storage_name, params

        response["results"]
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

        case conditions
        when NotOperation
          parse_query = Parse::Conditions::And.new
          feed_reversely(parse_query, conditions)
        when AndOperation
          parse_query = Parse::Conditions::And.new
          feed_directly(parse_query, conditions)
        when OrOperation
          parse_query = Parse::Conditions::Or.new
          feed_or(parse_query, conditions)
        end

        parse_query.build
      end

      def feed_for(parse_query, condition, comparison_class)
        subject = condition.subject
        case subject
        when DataMapper::Property
          comparison = comparison_class.new condition.value
          parse_query.add subject.field, comparison
        when DataMapper::Associations::OneToMany::Relationship
          child_key = condition.subject.child_key.first
          parse_query.add "objectId", comparison_class.new(condition.value.map { |resource| resource.send child_key.name })
        else
          raise NotImplementedError, "Condition: #{condition}"
        end
      end

      def feed_reversely(parse_query, conditions)
        conditions.each do |condition|
          case condition
          when EqualToComparison              then feed_for(parse_query, condition, Ne)
          when GreaterThanComparison          then feed_for(parse_query, condition, Lte)
          when GreaterThanOrEqualToComparison then feed_for(parse_query, condition, Lt)
          when LessThanComparison             then feed_for(parse_query, condition, Gte)
          when LessThanOrEqualToComparison    then feed_for(parse_query, condition, Gt)
          when NotOperation                   then feed_directly(parse_query, condition)
          when AndOperation                   then feed_reversely(parse_query, condition)
          when InclusionComparison            then feed_for(parse_query, condition, Nin)
          else
            raise NotImplementedError
          end
        end
      end

      def feed_directly(parse_query, conditions)
        conditions.each do |condition|
          feed_with_condition parse_query, condition
        end
      end

      def feed_or(queries, conditions)
        conditions.each do |condition|
          parse_query = Parse::Conditions::And.new
          feed_with_condition parse_query, condition
          queries.add parse_query
        end
      end

      def feed_with_condition(parse_query, condition)
        case condition
        when RegexpComparison               then feed_for(parse_query, condition, Regex)
        when EqualToComparison              then feed_for(parse_query, condition, Eql)
        when GreaterThanComparison          then feed_for(parse_query, condition, Gt)
        when GreaterThanOrEqualToComparison then feed_for(parse_query, condition, Gte)
        when LessThanComparison             then feed_for(parse_query, condition, Lt)
        when LessThanOrEqualToComparison    then feed_for(parse_query, condition, Lte)
        when InclusionComparison            then feed_for(parse_query, condition, In)
        when NotOperation                   then feed_reversely(parse_query, condition)
        when AndOperation                   then feed_directly(parse_query, condition)
        else
          raise NotImplementedError
        end
      end

    end

    const_added(:ParseAdapter)
  end
end
