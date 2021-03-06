# require 'sprockets'
# require 'sass'
# require 'sinatra/sprockets-helpers'
# require 'compass/import-once/activate'
# require 'sprockets-helpers'
# require 'tilt/erb'
# require 'compass/import-once/activate'

# module Hippo
#     module API
#         module SprocketsExtension
#             class << self

#                 def compile!
#                     # only require processor if it's needed
#                     # it requires asset pipeline functionality that requires a JS runtime
#                     # which may not be available on production
#                     require_relative 'javascript_processor'
#                     env = ::Sprockets::Environment.new
#                     Hippo::API::SprocketsExtension.configure(env, compress:true)
#                     JsAssetCompiler.register(env)
#                     manifest = Sprockets::Manifest.new( env.index, "public/assets/manifest.json" )
#                     manifest.compile('hippo/vendor.js', 'hippo.js', 'hippo.css')
#                     Extensions.each do |ext|
#                         ext.each_static_asset do | asset |
#                             manifest.compile( asset.to_s )
#                         end
#                     end
#                     Screen.each do | screen |
#                         [:js,:css].each do | type |
#                             asset = screen.url_path_for(type)
#                             manifest.compile( asset ) unless asset.blank?
#                         end
#                     end

#                 end

#                 def configure(env, compress:false)
#                     root = Pathname.new(__FILE__).dirname.join("../../..")
#                     Hippo.config.get(:environment) do
#                         unless Hippo.env.production?
#                             env.cache = ::Sprockets::Cache::FileStore.new(Pathname.pwd.join('tmp','cache'))
#                         end
#                     end

#                     Hippo::Extensions.each do | ext |
#                         ext.on_boot
#                         ext.client_paths.each{ |path|
#                             env.append_path(path)
#                         }
#                     end
#                     if compress
#                         env.js_compressor  = :uglifier
#                         env.css_compressor = :sass
#                     end
#                     # assets are pre-compiled on production
#                     unless Hippo.env.production?
#                         require_relative 'javascript_processor'
#                         JsAssetCompiler.register(env)
#                     end
#                     env.append_path root.join('client')
#                 end

#                 def registered(app)
#                     app.register Sinatra::Sprockets::Helpers
#                     app.set :sprockets, ::Sprockets::Environment.new
#                     configure(app.sprockets)

#                     app.configure do
#                         ::Sprockets::Helpers.configure do |config|
#                             config.environment = app.sprockets
#                             config.prefix      = Hippo.config.assets_path_prefix

#                             config.public_path = app.public_folder
#                             config.debug = !app.production?
#                             if app.production?
#                                 config.manifest = Sprockets::Manifest.new(app.sprockets,
#                                                                           "public/assets/manifest.json")
#                             end
#                         end
#                     end

#                     Root::CORS_PATHS['/assets/*'] = {origins: '*', methods: [:get]}

#                     app.configure :test, :development do
#                         app.get "#{Hippo.config.assets_path_prefix}/*" do |path|
#                             env_sprockets = request.env.dup
#                             env_sprockets['PATH_INFO'] = path.gsub(/\?\d+$/, '')
#                             settings.sprockets.call env_sprockets
#                         end
#                     end
#                     app.configure :production do
#                         app.get "#{Hippo.config.assets_path_prefix}/*" do |path|
#                             if manifest_path = ::Sprockets::Helpers.manifest.assets[path]
#                                 path = manifest_path
#                             end
#                             send_file "public/assets/" + path
#                         end
#                     end
#                 end

#             end
#         end
#     end
# end
