# frozen_string_literal: true

Rails.application.routes.draw do
  resources :principals, only: :update
  resources :establishments, only: :index

  resources :classes, only: %i[show index] do
    member do
      get "bulk_pfmp"
      post "create_bulk_pfmp"
    end

    resources :students, only: %i[show] do
      resources :pfmps
      resources :ribs
    end
  end

  resources :pfmps, only: :index do
    post "validate"
    collection do
      get "validate_all", to: "pfmps#validate_all"
    end
  end

  devise_for :principals, controllers: { omniauth_callbacks: "principals/omniauth_callbacks" }

  devise_scope :principal do
    # get "/login", to: "devise/sessions#new"
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_principal_session
  end

  root "home#index"

  get "/login", to: "home#login"
  get "/select_etab", to: "home#select_etab"
end
