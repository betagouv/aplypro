# frozen_string_literal: true

module Users
  # rubocop:disable Metrics/ClassLength
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include DeveloperOidc

    skip_before_action :verify_authenticity_token

    rescue_from IdentityMappers::Errors::Error, ActiveRecord::RecordInvalid, with: :authentication_failure

    def developer
      oidcize_dev_hash(auth_hash)

      oidc
    end

    def oidc
      parse_identity

      @user.save!

      check_limited_access!

      begin
        check_responsibilites!
      rescue IdentityMappers::Errors::EmptyResponsibilitiesError
        begin
          check_access_list!
        rescue IdentityMappers::Errors::NotAuthorisedError
          raise IdentityMappers::Errors::NoAccessFound
        end
      end

      log_user_in!
      save_roles!
      fetch_establishments!
      choose_redirect_page!
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

      sign_out(current_user) if user_signed_in?

      redirect_to login_path, alert: t("auth.errors.#{key}")
    end

    private

    def parse_identity
      data = auth_hash
      raw = data.extra.raw_info

      @user = User.from_oidc(data)

      @mapper = case data.provider.to_sym
                when :fim
                  IdentityMappers::Fim.new(raw)
                when :masa
                  IdentityMappers::Cas.new(raw)
                else
                  raise "No mapper suitable for auth provider: #{data.provider}"
                end
    end

    def save_roles!
      @mapper.establishments_in_responsibility.each do |e|
        e.save! unless e.persisted?

        EstablishmentUserRole
          .where(user: @user, establishment: e, role: :dir)
          .first_or_create
      end

      @mapper.establishments_authorised_for(@user.email).each do |e|
        e.save! unless e.persisted?

        EstablishmentUserRole
          .where(user: @user, establishment: e, role: :authorised)
          .first_or_create
      end
    end

    def log_user_in!
      sign_in(@user)
      Sentry.set_user(id: @user.id)
    end

    def check_responsibilites!
      raise(IdentityMappers::Errors::EmptyResponsibilitiesError, nil) if @mapper.no_responsibilities?
    end

    def check_access_list!
      raise(IdentityMappers::Errors::NotAuthorisedError, nil) if @mapper.no_access_for_email?(@user.email)
    end

    def choose_redirect_page!
      establishments = @user.establishments

      fetch_students_for!(establishments)

      if establishments.many?
        clear_previous_establishment!
        @inhibit_nav = true

        render action: :select_etab
      else
        @user.update!(establishment: establishments.first)

        redirect_to root_path, notice: t("auth.success")
      end
    end

    def fetch_students_for!(establishments)
      ActiveJob.perform_all_later(establishments.map { |e| FetchStudentsJob.new(e) })
    end

    def fetch_establishments!
      @mapper.establishments_in_responsibility.each { |e| FetchEstablishmentJob.perform_now(e) }
    end

    def clear_previous_establishment!
      @user.update!(establishment: nil)
    end

    def check_limited_access!
      allowed_uais = ENV
                     .fetch("APLYPRO_RESTRICTED_ACCESS", "")
                     .split(",")
                     .map(&:strip)

      return if allowed_uais.blank?

      allowed = allowed_uais.intersect?(@mapper.all_indicated_uais)

      raise IdentityMappers::Errors::NoLimitedAccessError unless allowed
    end

    def auth_hash
      request.env["omniauth.auth"]
    end
  end
end
# rubocop:enable Metrics/ClassLength
