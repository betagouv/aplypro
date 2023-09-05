# frozen_string_literal: true

module Principals
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token

    def developer
      @principal = Principal.from_developer(data)

      return unless @principal.save!

      sign_in_and_redirect @principal
    end

    def fim
      @principal = Principal.from_fim(data)
      @mapper = IdentityMappers::Fim.new(fim_extra_data).tap(&:create_all_establishments!)

      if @principal.save!
        sign_in(@principal) and redirect_or_update
      else
        redirect_to login_path, alert: t("auth.failure")
      end
    end

    private

    def redirect_or_update
      if @mapper.establishments.many?
        render action: :select_etab
      else
        @principal.update!(establishment: @mapper.establishments.first)

        redirect_to classes_path, notice: t("auth.success")
      end
    end

    def data
      request.env["omniauth.auth"]
    end

    def fim_extra_data
      data["extra"]["raw_info"]
    end
  end
end
