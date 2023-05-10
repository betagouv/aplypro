# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :principals, controllers: { omniauth_callbacks: 'principals/omniauth_callbacks' }

  root "home#index"
  get "/login", to: "home#login"
end
