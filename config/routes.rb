module Hippo::API

    routes.for_extension 'hippo' do
        get 'job-status/:id.json' do
            wrap_reply do
                status = Hippo::Job.status_for_id(params[:id])
                raise ActiveRecord::RecordNotFound unless status
                std_api_reply :update, status, success: true
            end
        end

        post "user-session.json", &Hippo::API::Handlers::UserSession.create
        get "user-session/test.json", &Hippo::API::Handlers::UserSession.check

        delete "user-session.json" do
            wrap_reply do
                { success: true, message: "Logout succeeded", data: {}, token: '' }
            end
        end

        get 'bootstrap.json' do
            wrap_reply do
                { success: true, data: Hippo::Extensions.client_bootstrap_data }
            end
        end

        get 'user/current.json' do
            with_user {|user| { success: true, data: user } }
        end

        resources Hippo::User
        resources Hippo::Tenant,
                  controller: Hippo::API::Handlers::Tenant,
                  cors: '*', public: true
        resources Hippo::Subscription,
                  controller: Hippo::API::Handlers::Subscription
        resources Hippo::Page
    end

    routes.draw do

        put Hippo.config.api_path + '/hippo/system-settings.json',
            &Hippo::SystemSettings.update_handler

        get Hippo.config.api_path + '/hippo/system-settings.json',
            &Hippo::SystemSettings.get_handler

        post Hippo.config.api_path + Hippo.config.assets_path_prefix,
             &Hippo::API::Handlers::Asset.saver

        delete Hippo.config.api_path + Hippo.config.assets_path_prefix + '/:id.json',
               &Hippo::API::Handlers::Asset.deleter

        get Hippo.config.api_path + Hippo.config.assets_path_prefix + '/*',
            &Hippo::API::Handlers::Asset.file_getter

        get Hippo.config.assets_path_prefix + '/:asset.js',
            &Hippo::API::Handlers::Asset.asset_getter

        get Hippo.config.api_path + Hippo.config.print_path_prefix + '/:template_id/:model_id.pdf',
            &Hippo::API::Handlers::Print.getter

    end

end

Hippo::API::Routing.root_view_route ||= lambda do
    Hippo::API::Root.get '/*' do
        erb :hippo_root_view
    end
end
