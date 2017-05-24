require 'oj'

module Hippo::API
    def self.to_json(data)
        Oj.dump(data, mode: :compat, time_format: :xmlschema)
    end
end