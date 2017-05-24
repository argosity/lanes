require_relative './webpack/client_config'

module Hippo
    class Webpack
        mattr_accessor :stub
        attr_reader :driver, :assets, :process

        def initialize
            @assets = {}
            root = Hippo::Extensions.controlling.root_path

            @config = ClientConfig.new
            @config.invoke_all

            @driver = WebpackDriver::Configuration.new(
                directory: root,
                logger: Hippo.logger,
                file: root.join('config', 'webpack.config.js'),
                cmd_line_flags: Hippo.env.production? ? [] : ['--hot', '--inline'],
                environment: { NODE_ENV: Hippo.env.production? ? 'production' : 'development' }
            )
            @process = @driver.launch(development: !Hippo.env.production?)
        end

        def start
            if Hippo.env.development? && !Hippo::Webpack.stub
                process.start
            end
        end

        def wait_until_available
            return if Hippo.env.production?
            Hippo.logger.warn("waiting while compilation in progress") if busy?
            sleep 0.5 while busy?
        end

        def busy?
            driver.process.in_progress?
        end

        def file(entry)
            if Webpack.stub
                "#{entry}.js"
            else
                asset = @driver.process.assets[entry]
                raise ArgumentError, "asset '#{entry}' was not found" unless asset
                asset.file
            end
        end

        def host
            Hippo.env.production? ? "" :
                "//#{@driver.process.host}:#{@driver.process.port}"
        end
    end
end