require_relative './formatted_reply'

module Hippo
    module API

        # The Controller handles querying models
        # using either pre-defined scopes or hash based queries;
        # and also including optional associations with the reply
        #
        # It assigns the following meaning the these parameters.
        #    * f: (fields)   Include the following fields (usually methods) with the reply
        #    * w: (with)     Uses the defined scope to query and/or add extra data to the model
        #    * q: (query)    Query the model using fields and values
        #         it is an array of clauses, which can be either forms
        #         { field: value }, or { field: { op: 'like', value: 'value%' } }
        #    * i: (include)  Include associations along with the model in the reply
        #    * o: (order)    Order by, { field => "ASC|DESC" }
        #    * l: (limit)    Limit the returned rows to the count
        #    * s: (start)    Start the query at the given offset (for paging)
        #    * df: (data format) Should data be returned as 'object' (default) or 'array'
        # The parameters are deliberately shortened so they can be used in
        # query parameters without blowing the URL up to an unacceptable length

        class ControllerBase

            attr_reader :model, :params, :data
            include FormattedReply

            def initialize(model, authentication, params, data={})
                @model  = model
                @params = params
                @data   = data
                @authentication = authentication
            end

            protected

            def current_user
                @current_user ||= @authentication.current_user
            end

            def perform_retrieval
                query   = build_query
                query   = add_scopes_to_query(query)
                query   = add_access_limits_to_query(query)
                options = build_reply_options
                if should_include_total_count?
                    options[:total_count] = count_query_records(query)
                end
                query = add_modifiers_to_query(query)
                query = query.first! if params[:id]
                std_api_reply(:retrieve, query, options)
            end

            def perform_single_destroy
                query = model.where(id: params[:id])
                query = add_access_limits_to_query(query)
                record = query.first!
                record.destroy
                std_api_reply(:destroy, record, {})
            end

            def perform_multiple_destroy
                query = model.where(id: data.map { |rec| rec['id'] })
                query = add_access_limits_to_query(query)
                success = true
                query.each do |record|
                    if current_user.can_delete?(record, record.id)
                        success = false unless record.destroy
                    end
                end
                options = build_reply_options.merge(success: success)
                std_api_reply(:destroy, query, options)
            end

            def perform_multiple_updates
                query = model.where(id: data.map { |rec| rec['id'] })
                query = add_access_limits_to_query(query)
                success = true
                query.each do |record|
                    record_data = data.detect { |rd| rd['id'] == record.id }
                    next unless record_data
                    if current_user.can_write?(record, record.id)
                        record.set_attribute_data(record_data, current_user)
                        success = false unless record.save
                    end
                end
                options = build_reply_options.merge(success: success)
                std_api_reply(:update, query, options)
            end

            def perform_single_update
                query = build_query
                query = add_access_limits_to_query(query)
                record = query.first!
                record.set_attribute_data(data, current_user)
                options = build_reply_options.merge(success: record.save)
                std_api_reply(:update, record, options)
            end

            # @return [Array<String>] The fields to include in query.  May represent either an attribute or a method
            def requested_fields
                [*params[:f]]
            end
            def reply_with_array?
                params[:df] == 'array'
            end
            def query_scopes
                [*params[:w]]
            end
            def query_params
                params[:q]
            end
            def include_associations
                [*params[:i]]
            end
            def sort_order
                params[:o]
            end
            def query_limit_size
                limit = max_query_results_size
                requested_limit ? [requested_limit, limit].min : limit
            end
            def query_offset
                params[:s]
            end
            def requested_limit
                params.key?(:l) ? params[:l].to_i : nil
            end

            # reply options

            # Should the result include the total number of available records
            def should_include_total_count?
                requested_limit && params[:id].blank?
            end

            # Extract options that are suitable for use in 'as_json'
            def build_reply_options
                options = {}
                if include_associations.any?
                    options[:include] = include_associations.each_with_object({}) do |association, includes|
                        includes.merge! build_allowed_associations(association)
                    end
                end

                if requested_fields.any?
                    options[:methods] = requested_fields.select do |f|
                        model.has_exported_method?(f, current_user)
                    end
                end
                options[:format] = reply_with_array? ? 'array' : 'object'
                options
            end

            def build_allowed_associations(association, model_class = self.model)
                includes = {}
                if association.is_a?(Hash)
                    association.each do |include_name, sub_associations|
                        if model_class.has_exported_association?(include_name, current_user) &&
                           (reflection = model_class.reflect_on_association(include_name.to_sym))

                            sub_includes = includes[include_name.to_sym] = {}
                            allowed = build_allowed_associations(sub_associations, reflection.klass)
                            unless allowed.empty?
                                sub_includes[:include] ||= []
                                sub_includes[:include] << allowed
                            end
                        end
                    end
                elsif association.is_a?(Array)
                    association.each do |sub_association|
                        if model_class.has_exported_association?(sub_association, current_user)
                            includes.merge! build_allowed_associations(sub_association, model_class)
                        end
                    end
                else
                    includes[association.to_sym] = {} if  model_class.has_exported_association?(association, current_user)
                end
                includes
            end

            # query options

            def add_access_limits_to_query(query)
                if model.respond_to?(:access_limits_for_query)
                    model.access_limits_for_query(query, current_user, params)
                else
                    query
                end
            end

            def build_query(query = model.all)
                query = query.where(id: params[:id]) if params[:id]
                if params[:nested_attribute]
                    query = query.where(params[:nested_attribute])
                end
                query = add_access_limits_to_query(query)
                query = add_params_to_query(query) if query_params.present?
                query
            end

            def count_query_records(query)
                query.unscope(:select).count
            end

            def add_scopes_to_query(query)
                query = add_scope_to_query(query) if query_scopes.present?
                query
            end

            def add_modifiers_to_query(query)
                query = query.limit(query_limit_size)
                query = query.offset(query_offset.to_i) if query_offset.present?

                if include_associations.any?
                    allowed_includes = include_associations.each_with_object([]) do |desired, results|
                        if desired.is_a?(Hash)
                            nested = {}
                            desired.each do |name, sub_associations|
                                nested[name.to_sym] = sub_associations if model.has_exported_association?(name, current_user)
                            end
                            results.push(nested) unless nested.empty?
                        else
                            results.push(desired.to_sym) if model.has_exported_association?(desired, current_user)
                        end
                    end
                    query = query.includes(allowed_includes) unless allowed_includes.empty?
                end
                if sort_order.present?
                    sort_order.each do |fld, dir|
                        query = model.append_sort_to_query(
                            query, fld, dir.downcase.to_sym
                        )
                    end
                end
                query
            end

            def max_query_results_size
                250 # should be enough for everybody, amirite?
            end

            def add_scope_to_query(query)
                query_scopes.each do |name, arg|
                    next unless model.has_exported_scope?(name, current_user)
                    args = [name]
                    args.push(arg) unless arg.blank?
                    query = query.send(*args)
                end
                query
            end

            def add_params_to_query(query)
                query_params.each do |field, value|
                    next unless (field = convert_field_to_arel(field))
                    if value.is_a?(Hash) && value.key?('value')
                        op = value['op']
                        value = value['value']
                    end
                    query = query.where(
                        field_to_predicate(field, value, op)
                    )
                end
                query
            end

            def convert_field_to_arel(field)
                if field.include?('.')
                    (table_name, field_name) = field.split('.')
                    if model.has_exported_join_table?(table_name, current_user)
                        Arel::Table.new(table_name)[field_name]
                    else
                        nil
                    end
                elsif model.attribute_method?(field)
                    model.arel_table[field]
                else
                    Arel::Nodes::SqlLiteral.new(
                        model.connection.quote_column_name(field)
                    )
                end
            end

            # complete list: https://github.com/rails/arel/blob/master/lib/arel/predications.rb
            def field_to_predicate(field, value, op = nil)
                case op
                when nil, 'eq' then field.eq(value)
                when 'like' then field.matches(value)
                when 'ne'   then field.not_eq(value)
                when 'lt'   then field.lt(value)
                when 'in'   then field.in(Range.new(*value))
                when 'gt'   then field.gt(value)
                when 'between' then field.between(Range.new(*value.split('...')))
                else
                    value =~ /%/ ? field.matches(value) : field.eq(value)
                end
            end
        end
    end
end
