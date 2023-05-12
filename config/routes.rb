# frozen_string_literal: true

Rails.application.routes.draw do
  resources :establishments, only: :index

  devise_for :principals, controllers: { omniauth_callbacks: 'principals/omniauth_callbacks' }

  root "home#index"
  get "/login", to: "home#login"
end
