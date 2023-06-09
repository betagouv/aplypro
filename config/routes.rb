# frozen_string_literal: true

Rails.application.routes.draw do
  resources :establishments, only: :index

  resources :classes, only: %i[show index] do
    resources :students, only: %i[show] do
      resources :pfmps
      resources :ribs
    end
  end

  devise_for :principals, controllers: { omniauth_callbacks: "principals/omniauth_callbacks" }

  devise_scope :principal do
    # get "/login", to: "devise/sessions#new"
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_principal_session
  end

  root "home#index"

  get "/login", to: "home#login"
  get "/pfmps", to: "classes#pfmps"
end
