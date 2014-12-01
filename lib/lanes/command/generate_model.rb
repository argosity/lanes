require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateModel < Thor::Group
            RESERVED_YAML_KEYWORDS = %w(y yes n no true false on off null)
            OPTIONS={
                timestamps: true,
                parent:    "Lanes::Model",
                client_collection_parent: "Lanes.Data.Collection"
            }

            include Thor::Actions

            class_options OPTIONS#  :directory,  type: :string
            # class_option :timestamps, type: :boolean, default: true
            # class_option :parent,     type: :string,  default: "Lanes::Model"
            # class_option :client_collection_parent, type: :string, default: "Lanes.Data.Collection"
            argument :name
            argument :fields, type: :array, default: []

            attr_reader :namespace, :file_name, :class_name, :table_name

            def self.source_root
                Pathname.new(__FILE__).dirname.join("templates")
            end

            def initialize(*args)
                super
                if name=~/::/
                    (@namespace,@name) = name.split("::")
                else
                    @namespace = computed_namespace
                end
                @class_name = name.camelize
                @file_name  = name.underscore
                @table_name = namespace + "_" + name.tableize
            end

            def create_migration
                migration = exising_migration || Time.now.utc.strftime("%Y%m%d%H%M%S") + "_create_#{table_name}.rb"
                self.fields = fields.map{ |field| ModelAttribute.parse(field) }
                template "db/create_table_migration.rb", "db/migrate/#{migration}"
            end

            def create_model
                template "lib/namespace/model.rb", "lib/#{namespace}/#{file_name}.rb"
                template "spec/namespace/model_spec.rb", "spec/#{namespace}/#{file_name}.rb"
                template "spec/fixtures/namespace/model.yml", "spec/fixtures/#{namespace}/#{file_name}.yml"
            end

            def create_client
                template "client/data/Model.coffee", \
                         "client/data/#{class_name}.coffee"
                template "spec/client/data/ModelSpec.coffee", \
                         "spec/client/data/#{class_name}Spec.coffee"
            end

            def add_route
                insert_into_file "config/routes.rb", before: "end" do
                    "    resources #{namespace.camelize}::#{class_name}\n"
                end
            end

          private

            def fields_with_index
                fields.select { |a| !a.reference? && a.has_index? }
            end

            def exising_migration
                migrations = Pathname.glob("#{destination_root}/db/migrate/[0-9]*_create_#{table_name}.rb")
                migrations.any? ? migrations.first.basename.to_s : nil
            end

            def computed_namespace
                # find a file and directory with the same basename
                entries = Dir.glob(self.destination_root + "/lib/*")
                name = entries.detect{ |directory|
                    FileTest.directory?(directory) && entries.detect{ |file|
                        file == directory+".rb"
                    }
                }
                name ? File.basename(name).to_s : nil
            end

            def yaml_key_value(key, value)
                if RESERVED_YAML_KEYWORDS.include?(key.downcase)
                    "'#{key}': #{value}"
                else
                    "#{key}: #{value}"
                end
            end

            def client_parent
                if options[:parent] == 'Lanes::Model'
                    "Lanes.Data.Model"
                else
                    "Lanes.#{namespace.camelize}.#{options[:parent]}"
                end
            end

            def max_field_length
                @max_field_length ||= fields.map{|field|
                    field.name.length + ( field.reference? ? 3 : 0 )
                }.max
            end

            def reference_fields
                fields.select { |a| a.reference? }
            end
        end
    end
end