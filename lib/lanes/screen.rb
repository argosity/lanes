require 'yaml'
require 'oj'
require 'pry'

module Lanes

    module Screen
        GROUPS=Hash.new{|h,k| g=Group.new; g.identifier=k; h[k]=g }
        DEFINITIONS=Hash.new{|h,k| d=Definition.new; d.identifier=k; h[k]=d }

        class << self
            def [](config)
                if DEFINITIONS.has_key?(config)
                    DEFINITIONS[config]
                else
                    nil
                end
            end

            def define(id)
                definition = DEFINITIONS[id]
                yield definition
            end

            def define_group(id)
                group = GROUPS[id]
                yield group
            end

            def each
                Extensions.load_screens
                DEFINITIONS.values.each{ | definition | yield definition }
            end

            def each_group
                Extensions.load_screens
                GROUPS.values.each{ | group | yield group }
            end

            def config_file
                Lanes::Extensions.controlling.root_path.join("config","screens.rb")
            end

            def uncache_file_on_update(asset)
                asset.depend_on(config_file) if config_file.exist?
            end
        end

        class Group
            include Concerns::AttrAccessorWithDefault

            attr_accessor_with_default :identifier
            attr_accessor_with_default :title
            attr_accessor_with_default :description
            attr_accessor_with_default :icon

            def to_json
                Oj.dump({
                    id: identifier,
                    title: title,
                    description: description,
                    icon: icon
                }, mode: :compat)
            end
        end

        class Definition
            include Concerns::AttrAccessorWithDefault

            attr_accessor_with_default :identifier
            attr_accessor_with_default :title
            attr_accessor_with_default :description
            attr_accessor_with_default :icon
            attr_accessor_with_default :group_id
            attr_accessor_with_default :view_class
            attr_accessor_with_default :model_class
            attr_accessor_with_default :js
            attr_accessor_with_default :css

            def assets
                paths=[]
                paths << "#{Lanes.config.assets_path_prefix}/#{js}"  unless js.blank?
                paths << "#{Lanes.config.assets_path_prefix}/#{css}" unless css.blank?
                paths
            end

            def to_json
                Oj.dump({
                    id:    identifier,
                    title: title,
                    icon:  icon,
                    model: model_class,
                    view:  view_class,
                    js:    js,
                    css:   css,
                    assets: assets,
                    group_id: group_id,
                    description: description
                }, mode: :compat)
            end
        end

    end

end
