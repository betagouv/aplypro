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

      begin
        check_responsibilites!
      rescue IdentityMappers::Errors::EmptyResponsibilitiesError
        check_access_list!
      rescue IdentityMappers::Errors::NoDelegationsError
        raise IdentityMappers::Errors::NoAccessFound
      end

      check_user!
      save_roles!
      check_limited_access!
      choose_roles!
      fetch_students!
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
      @mapper.establishments.each do |e|
        e.save! unless e.persisted?

        EstablishmentUserRole
          .where(user: @user, establishment: e, role: :dir)
          .first_or_create
      end

      @mapper.authorised_establishments_for(@user.email).each do |e|
        e.save! unless e.persisted?

        EstablishmentUserRole
          .where(user: @user, establishment: e, role: :authorised)
          .first_or_create
      end
    end

    def check_user!
      @user.save!

      sign_in(@user)
    end

    def check_responsibilites!
      raise(IdentityMappers::Errors::EmptyResponsibilitiesError, nil) if @mapper.responsibilities.none?
    end

    def check_access_list!
      authorisations = @mapper.authorised_establishments_for(@user.email)

      raise(IdentityMappers::Errors::NotAuthorisedError, nil) if authorisations.none?
    end

    def choose_roles!
      establishments = @user.establishments

      if establishments.many?
        clear_previous_establishment!
        establishments.each(&:fetch_data!)
        @inhibit_nav = true

        render action: :select_etab
      else
        @user.update!(establishment: establishments.first)

        redirect_to classes_path, notice: t("auth.success")
      end
    end

    def fetch_students!
      jobs = @mapper.establishments.map { |e| FetchStudentsJob.new(e) }

      ActiveJob.perform_all_later(jobs)
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

      allowed = @user.establishments.find { |e| allowed_uais.include?(e.uai) }

      raise IdentityMappers::Errors::NoLimitedAccessError unless allowed
    end

    def auth_hash
      request.env["omniauth.auth"]
    end
  end
end
# rubocop:enable Metrics/ClassLength
