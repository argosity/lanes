require_relative 'model_attribute'

module Lanes
    module Command

        class UpdateModel < Thor::Group

            include Thor::Actions

            argument :name
            attr_reader :namespace, :class_name, :namespaced_name

            def self.source_root
                Pathname.new(__FILE__).dirname.join("templates")
            end

            def read_class
                if name=~/::/
                    (@namespace,@name) = name.split("::")
                else
                    ext = Command.load_current_extension
                    @namespace = ext.identifier
                end
                class_name = name.camelize
                namespaced_name = "#{namespace.classify}::#{class_name}"
                @klass = namespaced_name.safe_constantize
                if !@klass
                    raise Thor::Error.new("#{namespaced_name} was not found")
                end
                @file = Pathname.new("client/data/#{class_name}.coffee")
                unless @file.exist?
                    raise Thor::Error.new("Model #{@file} doesn't exist")
                end
                Lanes::DB.establish_connection
            end

            def replace_props
                columns = columns_for(@klass)
                return unless columns.any? # could happen I guess?
                (props,indent) = read_indent('props')
                maxlen = columns.map{|field| field.name.length }.max
                contents = props
                columns.each do | column |
                    contents << sprintf("#{indent}%-#{maxlen+1}s",column.name+':') + type_specification(column) + "\n"
                end
                gsub_file @file, /props\s*:\s*\n.*?\n(?!#{indent})/m, contents
            end

            def replace_associations
                associations = associations_for(@klass)
                return unless associations.any?
                (section,indent) = read_indent('associations',optional: true)
                maxlen = associations.map{|field| field.name.length }.max
                contents = section || (
                               single_indent = @file.read[/\n(\h+)(\w+):/,1] || '    '
                               indent = single_indent*2
                               "\n#{single_indent}associations:\n"
                             )
                associations.each do | assoc |
                    type = assoc.collection? ? 'collection' : 'model'
                    contents << sprintf("#{indent}%-#{maxlen+2}s",assoc.name.to_s+':') + \
                                "{ #{type}: \"#{assoc.class_name.demodulize}\" }\n"
                end
                if section
                    gsub_file @file, /associations\s*:\s*\n.*?\n(?!#{indent})/m, contents
                else
                    gsub_file @file, /\n\z/m, contents
                end
            end

          private

            def read_indent(section, optional: false)
                  contents = @file.read
                  match = contents.match(/(#{section}\s*:\s*\n+)(\s+)\w/m)
                  return match.captures if match
                  if optional
                      return [nil,nil]
                  else
                      raise Thor::Error.new("Unable to detect #{section} section")
                  end
            end

            def type_specification(column)
                if column.null
                    '"' + type_for_column(column) + '"'
                else
                    type = { type: type_for_column(column), required: true }
                    if column.default
                        type[:default] = column.default
                    end
                    type.to_json
                end
            end

            def associations_for(klass)
                klass.reflect_on_all_associations.reject{|assoc| assoc.name =~ /^(created|updated)_by/ }
            end

            def columns_for(klass)
                klass.columns.reject{ |column| column.name =~ /^(created|updated)_/ }
            end

            def type_for_column(column)
                if column.array
                    'array'
                elsif column.sql_type == 'json'
                    'object'
                else
                    case column.type
                    when :datetime then 'date'
                    when :integer  then 'integer'
                    when :float    then 'number'
                    when :text     then 'string'
                    when :string   then 'string'
                    when :boolean  then 'boolean'
                    when :decimal  then 'bigdec'
                    else 'any'
                    end
                end
            end

        end
    end
end