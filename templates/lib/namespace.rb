require "lanes"
require 'require_all'
require_relative "<%= identifier %>/version.rb"
require_relative "<%= identifier %>/extension.rb"

# The main namespace for <%= namespace %>
module <%= namespace %>

    def self.system_settings
        Lanes::SystemSettings.for_ext('<%= identifier %>')
    end

end

require_relative "<%= identifier %>/model"
