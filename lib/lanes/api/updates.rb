module Lanes

    module API

        module Updates
            @relaying_messages = false

            def self.user_info_for_change(model)
                if model.class.reflect_on_aggregation(:updated_by)
                    model.updated_by.as_json(only:[:id,:name,:email])
                else
                    {}
                end
            end

            def self.relay!
                if @relaying_messages
                    raise "Already relaying messages, calling relay! twice will lead to message duplication"
                end
                @relaying_messages = true
                Lanes::Model.observe(:save) do |model|
                    if model.changes.any?
                        path = "/#{model.class.api_path(with_module: true)}/#{model.id}"
                        Lanes::API::PubSub.publish(path, {
                            by: self.user_info_for_change(model),
                            update: model.changes
                        })
                    end
                end

            end

        end


    end
end
