# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  resources :users, only: :update

  resources :establishments, only: %w[edit update] do
    resources :invitations

    post "create_attributive_decisions"
  end

  resources :classes, only: %i[show index] do
    member do
      get "bulk_pfmp"
      post "create_bulk_pfmp"
    end

    resources :students, only: %i[show] do
      resources :pfmps do
        member do
          post "validate"
          get "confirm_deletion"
        end
      end

      resources :ribs
    end
  end

  resources :pfmps, only: :index do
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

  get "/maintenance", to: "home#maintenance"
  get "/login", to: "home#login"
  get "/select_etab", to: "home#select_etab"
  get "/legal", to: "home#legal"
end
# rubocop:enable Metrics/BlockLength
