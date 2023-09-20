# frozen_string_literal: true

module Principals
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token

    def developer
      @principal = Principal.from_developer(data)

      return unless @principal.save!

      sign_in_and_redirect @principal
    end

    def oidc
      parse_identity

      begin
        check_principal!
        check_responsibilites!
        check_multiple_etabs!
      rescue IdentityMappers::Errors::EmptyResponsibilitiesError => e
        Sentry.capture_exception(e)

        redirect_to login_path, alert: t("auth.no_responsibilities") and return
      end
    end

    def masa
      oidc
    end

    def fim
      oidc
    end

    private

    def parse_identity
      data = auth_hash
      raw = data.extra.raw_info

      @principal = Principal.from_oidc(data)

      @mapper = case data.provider.to_sym
                when :fim
                  IdentityMappers::Fim.new(raw)
                when :masa
                  IdentityMappers::Cas.new(raw)
                else
                  raise "No mapper suitable for auth provider: #{data.provider}"
                end
    end

    def check_principal!
      redirect_to login_path, alert: t("auth.failure") and return unless @principal.save

      sign_in(@principal)
    end

    def check_responsibilites!
      raise(IdentityMappers::Errors::EmptyResponsibilitiesError, nil) if @mapper.responsibilities.none?
    end

    def check_multiple_etabs!
      if @mapper.establishments.many?
        @mapper.create_all_establishments!
        render action: :select_etab
      else
        @principal.update!(establishment: @mapper.establishments.first)

        redirect_to classes_path, notice: t("auth.success")
      end
    end

    def auth_hash
      request.env["omniauth.auth"]
    end
  end
end
