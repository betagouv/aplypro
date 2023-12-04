# frozen_string_literal: true

require "sidekiq/web"

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  resources :users, only: :update

  resources :establishments, only: %w[edit update] do
    resources :invitations

    post "create_attributive_decisions"
    post "download_attributive_decisions"
  end

  resources :classes, only: %i[show index] do
    member do
      get "bulk_pfmp"
      post "create_bulk_pfmp"
    end

    resources :students, only: %i[show] do
      resources :pfmps, except: :index do
        member do
          post "validate"
          get "confirm_deletion"
        end
      end

      resources :ribs
    end
  end

  resources :pfmps, only: %i[index] do
    collection do
      get "validate_all", to: "pfmps#validate_all"
    end
  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    # get "/login", to: "devise/sessions#new"
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  root "home#index"

  get "/welcome", to: "home#welcome"
  get "/home", to: "home#home"

  get "/maintenance", to: "home#maintenance"
  get "/login", to: "home#login"
  get "/select_etab", to: "home#select_etab"
  get "/legal", to: "home#legal"
  get "/faq", to: "home#faq"

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

  mount Sidekiq::Web => "/sidekiq"
end
# rubocop:enable Metrics/BlockLength
