# frozen_string_literal: true

module Principals
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token

    def developer
      @principal = Principal.from_developer(data)

      save_and_redirect!
    end

    def fim
      @principal = Principal.from_fim(data)

      save_and_redirect!
    end

    private

    def save_and_redirect!
      if @principal.save!
        flash[:notice] = t("auth.success")
        sign_in_and_redirect @principal
      else
        flash[:alert] = t("auth.failure")
        redirect_to login_path
      end
    end

    def data
      request.env["omniauth.auth"]
    end
  end
end
