# -*- coding: utf-8 -*-
require 'logger'

module Hippo

    class MultiDestinationLogger
        def initialize
            @targets = [STDOUT]
            @targets.push(
                File.open("log/#{Hippo.config.environment}.log", "a")
            ) if File.writable?("log")
        end

        def write(*args)
            @targets.each {|t| t.write(*args)}
        end

        def close
            @targets.each(&:close)
        end

    end

    class << self
        def logger
            @logger ||= _create_logger
        end

        def logger=( logger )
            @logger = logger
        end

        def silence_logs( &block )
            old_logger = Hippo.logger
            begin
                Hippo.logger=Logger.new( StringIO.new )
                yield
            ensure
                Hippo.logger=old_logger
            end
        end

        def logger_debug( output )
            logger.debug '⚡ '*40
            logger.debug '⚡ ' + output
            logger.debug '⚡ '*40
        end

        private

        def _create_logger
            logger = ::Logger.new MultiDestinationLogger.new
            logger.formatter = proc do |severity, datetime, progname, msg|
                sprintf "%5.5s %s\n", severity, msg
            end
            if ENV['LOG']
                logger.level = ::Logger.const_get(ENV['LOG'].upcase)
            else
                logger.level = ::Logger::INFO
            end
            logger
        end
    end
end