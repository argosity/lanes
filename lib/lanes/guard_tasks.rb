require_relative "../lanes"
require 'guard/jasmine'
require 'guard/minitest'
require "net/http"
require "uri"
require_relative "hot_reload_plugin"

module Lanes
    module GuardTasks

        class CustomMatchers
            attr_reader :client_matches, :server_matches, :hot_reload

            def client(&block)
                @client_matches = block
            end
            def server(&block)
                @server_matches = block
            end
            def hot_reload(&block)
                @hot_reload = block
            end
        end


        def self.run(dsl, options, &block)
            app_name = options[:name] || Pathname.getwd.basename.to_s
            matchers = CustomMatchers.new
            yield matchers

            jasmine_options = options.merge({
               keep_failed: false,
               port: 8888, server_mount: '/spec',
               server_env: 'development',
               server: :puma, spec_dir: "spec/#{app_name}",
               console: :always, debug: false
            })


            minitest_options = {
              all_on_start: true, test_folders: 'spec/server'
            }
            coffee_files = %r{^client/(.+?)\.(js|coffee|cjsx)$}

            dsl.guard :hot_reload, port: jasmine_options[:port] do
                dsl.watch(coffee_files)
                dsl.watch(%r{\.scss$})
                matchers.hot_reload.call if matchers.hot_reload
            end

            dsl.guard :jasmine, jasmine_options do
                dsl.watch(coffee_files){ |m| "spec/#{m[0]}Spec.#{m[2]}" }
                dsl.watch(%r{^spec/.*(?:_s|S)pec\.(?:js|coffee|cjsx)$}){|m| p m[0]; m[0]}
                matchers.client_matches.call if matchers.client_matches
            end

            dsl.guard :minitest, minitest_options do
                dsl.watch(%r{^spec/server/spec_helper\.rb}) { 'test' }
                dsl.watch(%r{^spec/server/.*_spec\.rb})
                dsl.watch(%r{^spec/fixtures/#{app_name}/(.+)s\.yml})   { |m| "spec/server/#{m[1]}_spec.rb" }
                dsl.watch(%r{^lib/#{app_name}/(.+)\.rb})               { |m| "spec/server/#{m[1]}_spec.rb" }
                matchers.server_matches.call if matchers.server_matches
            end

        end

    end
end
