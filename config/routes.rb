# frozen_string_literal: true

require "sidekiq/web"

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  namespace :asp do
    resources :schoolings, only: %i[index show] do
      member do
        post :generate_liquidation
        get :download_liquidation
      end
    end

    devise_for :users, skip: :all, class_name: "ASP::User"
  end

  # this allows overriding the redirect-if-not-logged-in path that
  # Devise automatically looks for with "new_#{resource}_session_url"
  # path[1], but we need to get it out of the scoped block above
  # otherwise it ends up being `asp_new_asp_user_session_path`.

  # [1]: https://github.com/heartcombo/devise/blob/bb18f4d3805be0bf5f45e21be39625c7cfd9c1d6/lib/devise/failure_app.rb#L140
  get "asp/login", to: "asp/application#login", as: :new_asp_user_session

  delete "asp/logout", to: "asp/application#logout", as: :destroy_asp_user_session

  namespace :academic do
    root to: "application#home"
    get "home", to: "application#home"
    get "academic_map", to: "application#academic_map"

    resources :establishments, only: [:show] do
      member do
        get :users
      end
    end

    resource :students do
      get :search_results
    end

    resources :students do
      get :show
    end

    resources :school_years, path: :year, only: [] do
      get "selected"

      collection do
        get "select"
      end
    end

    resources :users, only: [:index]

    resource :users, only: [] do
      get "select_academy"
      post "set_selected_academy"
    end

    resources :tools, only: [:index] do
      collection do
        post "remove_keycloak_user"
        post "invite_keycloak_user"
        get "academic_invitations"
        get "establishment_invitations"
      end
    end

    resources :academic_invitations, only: [:destroy]

    resources :reports, only: %i[index show] do
      collection do
        get :global_evolution
      end
      member do
        get :global
        post :export
        get :establishments_table
      end
    end

    devise_for :users, class_name: "Academic::User"
  end

  get "academic/login", to: "academic/application#login", as: :new_academic_user_session

  delete "academic/logout", to: "academic/application#logout", as: :destroy_academic_user_session

  resources :users, only: :update do
    get "select_establishment"
  end

  resources :establishments, only: %w[edit update] do
    resources :invitations
  end

  resource :students do
    get "search_results"
  end

  resources :students, only: %i[show] do
    resources :ribs, only: %i[new create update edit]
  end

  resources :school_years, path: :year, only: [] do
    get "selected"

    collection do
      get "select"
    end

    get "/home", to: "home#home"

    resources :establishments, only: [] do
      post "create_attributive_decisions"
      post "reissue_attributive_decisions"
      post "download_attributive_decisions"
    end

    resources :classes, only: %i[show index] do
      member do
        get "bulk_pfmp"
        post "create_bulk_pfmp"
        get "bulk_pfmp_completion"
        put "update_bulk_pfmp"
        get "validation", to: "validations#show"
        post "validation", to: "validations#validate"
      end

      resources :ribs, only: [] do
        collection do
          get "missing"
          post "bulk_create"
        end
      end

      resources :schoolings, only: [:update] do
        member do
          get "confirm_abrogation"
          delete "abrogate_decision"
          get "confirm_cancellation_decision"
          get "cancellation_decision"
          get "confirm_da_extension"
          get "confirm_removal"
          get "confirm_removal_cancellation"
          post "remove"
          post "create_attributive_decision"
        end

        resources :pfmps, except: :index do
          member do
            post :validate
            get :confirm_deletion
            get :confirm_rectification
            post :rectify
            resources :payment_requests, only: %i[create update]
          end
        end
      end
    end

    resources :validations, only: :index
    resources :abrogations, only: :index
  end

  devise_scope :asp_user do
    get "/auth/asp/callback", to: "users/omniauth_callbacks#asp"
    post "/auth/asp_developer/callback", to: "users/omniauth_callbacks#asp_developer"
  end

  devise_scope :academic_user do
    get "/auth/academic/callback", to: "users/omniauth_callbacks#academic"
    post "/auth/academic_developer/callback", to: "users/omniauth_callbacks#academic_developer"
  end

  devise_for :users

  devise_scope :user do
    %w[fim masa developer].each do |action|
      match "/users/auth/#{action}/callback", to: "users/omniauth_callbacks##{action}", via: %i[get post]
    end

    get "login", to: "home#login", as: :new_user_session
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  root "home#index"

  get "/welcome", to: "home#welcome"
  get "/home", to: "home#home"
  get "/accessibility", to: "home#accessibility"

  get "/maintenance", to: "home#maintenance"
  get "/legal", to: "home#legal"
  get "/faq", to: "home#faq"

  resources :stats, only: [:index] do
    collection do
      get "paid_pfmps_per_month"
    end
  end

  if Rails.env.production?
    Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
      # https://github.com/sidekiq/sidekiq/wiki/Monitoring#rails-http-basic-auth-from-routes
      # Protect against timing attacks:
      # - See https://codahale.com/a-lesson-in-timing-attacks/
      # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use digests to stop length information leaking

      allowed_user = Digest::SHA256.hexdigest(ENV.fetch("APLYPRO_SIDEKIQ_USER", nil))
      allowed_password = Digest::SHA256.hexdigest(ENV.fetch("APLYPRO_SIDEKIQ_PASSWORD", nil))

      Rack::Utils.secure_compare(Digest::SHA256.hexdigest(user), allowed_user) &
        Rack::Utils.secure_compare(Digest::SHA256.hexdigest(password), allowed_password)
    end
  end

  mount Sidekiq::Web => "/sidekiq"
end
# rubocop:enable Metrics/BlockLength
