module DataMapper
  module Adapters

    class ParseAdapter < AbstractAdapter
      HOST              = "https://api.parse.com"
      VERSION           = "1"
      APP_ID_HEADER     = "X-Parse-Application-Id"
      API_KEY_HEADER    = "X-Parse-REST-API-Key"
      MASTER_KEY_HEADER = "X-Parse-Master-Key"

      attr_reader :classes, :users

      def initialize(name, options)
        super
        @classes  = build_parse_resource_for "classes"
        @users    = build_parse_resource_for "users"
      end

      def parse_resources_for(model)
        model.storage_name == "_User" ? users : classes[model.storage_name]
      end

      def parse_resource_for(resource)
        parse_resources_for(resource.model)[resource.id]
      end

      def create(resources)
        resources.each do |resource|
          params  = attributes_as_fields(resource.attributes(:property)).except("objectId", "createdAt", "updatedAt")
          model   = resource.model
          result  = parse_resources_for(model).post params: params
          initialize_serial resource, result["objectId"]
        end.size
      end

      def read(query)
        model     = query.model
        params    = parse_params_for(query)
        response  = parse_resources_for(model).get params: params
        response["results"]
      end

      def delete(resources)
        resources.each do |resource|
          parse_resource_for(resource).delete
        end.size
      end

      def update(attributes, resources)
        resources.each do |resource|
          params  = attributes_as_fields(attributes).except("createdAt", "updatedAt")
          parse_resource_for(resource).put(params: params)
        end.size
      end

      private
      def build_parse_resource_for(name)
        key_type  = @options[:master] ? MASTER_KEY_HEADER : API_KEY_HEADER
        headers   = {APP_ID_HEADER => @options[:app_id], key_type => @options[:api_key]}
        Parse::Resource.new(HOST, format: :json, headers: headers)[VERSION][name]
      end

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
        # cannot use objectId as order field on Parse
        orders = query.order.reject { |order| order.target.field == "objectId" }.map do |order|
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
        raise "Parse limit: only number from 1 to 1000 is valid" unless (1..1000).include?(limit)
        limit 
      end

      def parse_conditions_for(query)
        conditions = query.conditions
        return nil if conditions.blank?
        convert(conditions)
      end

      def convert(conditions)
        # Option "$ne" of Parse can be presented by
        # a single EqualToComparison under a NotOperation
        if conditions.slug == :not && conditions.first.slug != :eql
          raise "Parse does not support complex NOT operation"
        elsif conditions.slug == :or
          {"$or" => conditions.map { |condition| convert(condition) }}
        elsif conditions.slug == :and
          conditions.group_by { |condition| condition_field_for(condition) }.inject({}) do |result, (field, conditions)|
            result.merge(field => conditions_value_for(conditions))
          end
        elsif conditions.is_a?(Query::Conditions::AbstractComparison)
          {conditions.subject.field => condition_value_for(conditions)}
        end
      end

      def regex_options(regex)
        options = regex.options
        result = []
        result << "i" if options[0] == 1
        result << "m" if options[2] == 1
        result.join
      end

      def condition_field_for(condition)
        if condition.slug == :not
          condition.first.subject.field
        else
          condition.subject.field
        end
      end

      def condition_value_for(condition)
        slug = condition.slug

        if slug == :eql
          condition.value
        elsif [:gt, :gte, :lt, :lte].include?(slug)
          {"$#{slug}" => condition.value}
        elsif slug == :in
          {"$#{slug}" => condition.value.to_a}
        elsif slug == :regexp
          regex   = condition.value
          options = regex_options(regex)
          {"$regex" => regex.source}.tap { |v| v["$options"] = options if options.present? }
        elsif slug == :not
          first_condition = condition.first
          raise "Parse does not support complex NOT operation" unless first_condition.slug == :eql
          {"$ne" => first_condition.value}
        end
      end

      def conditions_value_for(conditions)
        groups = conditions.group_by { |condition| condition.slug == :eql }
        equal_conditions = groups[true]
        other_conditions = groups[false]

        if equal_conditions.present? && other_conditions.present?
          raise "cannot combine EqualToComparison with others for a field in Parse"
        end

        if equal_conditions.present? && equal_conditions.size > 1
          raise "can only use one EqualToComparison for a field"
        end

        if equal_conditions.present?
          equal_conditions.first.value
        else
          other_conditions.inject({}) do |result, condition|
            result.merge condition_value_for(condition)
          end
        end
      end
    end

    const_added(:ParseAdapter)
  end
end
