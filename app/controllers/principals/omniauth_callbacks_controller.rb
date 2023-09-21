# frozen_string_literal: true

module Principals
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token

    rescue_from IdentityMappers::Errors::Error, ActiveRecord::RecordInvalid, with: :authentication_failure

    def developer
      @principal = Principal.from_developer(auth_hash)

      @principal.save!

      sign_in_and_redirect @principal
    end

    def oidc
      parse_identity

      check_responsibilites!
      check_principal!
      check_multiple_etabs!
    end

    def masa
      oidc
    end

    def fim
      oidc
    end

    def failure
      raise IdentityMappers::Errors::OmniauthError, request.env["omniauth.error"]&.message
    end

    def authentication_failure(error)
      Sentry.capture_exception(error)

      key = error.class.to_s.demodulize.underscore

      redirect_to login_path, alert: t("auth.errors.#{key}")
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
      @principal.save!

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
