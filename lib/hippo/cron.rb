module Hippo

    class Cron
        include Hippo::Concerns::PubSub
        valid_event_names << :daily

        class << self

            def daily(&block)
                observe(:daily, &block)
            end

            def trigger(type)
                _event_listeners[type].each{ | block |
                    begin
                        block.call
                    rescue => e
                        Hippo.logger.warn e
                    end
                }
            end

        end

    end

end
