# frozen_string_literal: true

module Users
  # rubocop:disable Metrics/ClassLength
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include DeveloperOidc

    class UserMailDuplicateError < StandardError; end

    skip_before_action :verify_authenticity_token

    rescue_from IdentityMappers::Errors::Error, ActiveRecord::RecordInvalid, with: :authentication_failure

    def developer
      oidcize_dev_hash(auth_hash)

      oidc
    end

    def academic_developer
      oidcize_dev_hash(auth_hash)

      academic
    end

    def asp_developer
      oidcize_dev_hash(auth_hash, false)

      asp
    end

    def masa
      oidc
    end

    def fim
      oidc
    end

    def oidc
      parse_identity

      inflate_user

      add_auth_breadcrumb(data: { user_id: @user.id }, message: "Successfully parsed user")

      check_access!

      add_auth_breadcrumb(data: { user_uais: @mapper.all_indicated_uais }, message: "Found establishments")

      log_user_in!
      delete_old_roles!
      save_roles!
      fetch_establishments!
      choose_redirect_page!
    end

    def academic # rubocop:disable Metrics/AbcSize
      parse_identity

      @academic_login = true
      @academic_user = Academic::User.from_oidc(auth_hash).tap(&:save!)

      add_auth_breadcrumb(data: { user_id: @academic_user.id }, message: "Successfully parsed academic user")

      @academies = @mapper.aplypro_academies

      raise IdentityMappers::Errors::EmptyResponsibilitiesError if @academies.empty?

      sign_in(:academic_user, @academic_user)
      session[:academy_codes] = @academies

      if @academies.many?
        redirect_to select_academy_academic_users_path(@academic_user)
      else
        session[:selected_academy] = @academies.first

        redirect_to academic_home_path, notice: t("auth.success")
      end
    end

    def asp
      @asp_login = true
      @asp_user = ASP::User.from_oidc(auth_hash).tap(&:save!) # TODO: "save!" ne marche pas

      add_auth_breadcrumb(data: { user_id: @asp_user.id }, message: "Successfully parsed asp user")

      sign_in(:asp_user, @asp_user)

      redirect_to asp_schoolings_path, notice: t("auth.success")
    end

    def failure
      raise IdentityMappers::Errors::OmniauthError, request.env["omniauth.error"]&.message
    end

    def authentication_failure(error)
      Sentry.capture_exception(error)

      key = error.class.to_s.demodulize.underscore

      flash[:alert] = t("auth.errors.#{key}")

      if defined? @asp_login
        fail_asp_user
      elsif defined? @academic_login
        fail_academic_user
      else
        fail_user
      end
    end

    def fail_user
      sign_out(current_user) if user_signed_in?

      redirect_to new_user_session_path
    end

    def fail_asp_user
      redirect_to new_asp_user_session_path
    end

    def fail_academic_user
      redirect_to new_academic_user_session_path
    end

    private

    def check_access!
      check_responsibilities!
    rescue IdentityMappers::Errors::EmptyResponsibilitiesError
      begin
        check_access_list!
      rescue IdentityMappers::Errors::NotAuthorisedError
        raise IdentityMappers::Errors::NoAccessFound
      end
    end

    def parse_identity
      data = auth_hash
      raw = data.extra.raw_info

      @mapper = case data.provider.to_sym
                when :fim, :academic
                  IdentityMappers::Fim.new(raw)
                when :masa
                  IdentityMappers::Cas.new(raw)
                else
                  raise "No mapper suitable for auth provider: #{data.provider}"
                end
    end

    def save_roles!
      # Manage authorised establishments first, just in case someone has a
      # former authorisation for an establishment now in responsibility.
      @mapper.establishments_authorised_for(@user.email).each do |establishment|
        save_role(establishment, :authorised)
      end

      @mapper.establishments_in_responsibility.each do |establishment|
        save_role(establishment, :dir)
      end
    end

    def save_role(establishment, role)
      EstablishmentUserRole
        .find_or_create_by(user: @user, establishment: establishment)
        .update(role: role)
    end

    def delete_old_roles!
      EstablishmentUserRole.where(user: @user).find_each do |access|
        unless @mapper.establishments_in_responsibility_and_delegated.include?(access.establishment)
          current_dir = access.establishment.confirmed_director
          access.establishment.update!(confirmed_director: nil) if @user.eql?(current_dir)
          access.destroy!
        end
      end
    end

    def log_user_in!
      sign_in(@user)
      Sentry.set_user(id: @user.id)
    end

    def check_responsibilities!
      raise(IdentityMappers::Errors::EmptyResponsibilitiesError, nil) if @mapper.no_responsibilities?
    end

    def check_access_list!
      raise(IdentityMappers::Errors::NotAuthorisedError, nil) if @mapper.no_access_for_email?(@user.email)
    end

    def choose_redirect_page!
      establishments = @user.establishments

      fetch_students_for!(establishments)

      if establishments.many?
        @inhibit_banner = true
        @inhibit_nav = true

        render action: :select_etab
      else
        @user.update!(selected_establishment: establishments.first)

        redirect_to root_path, notice: t("auth.success")
      end
    end

    def fetch_students_for!(establishments)
      ActiveJob.perform_all_later(establishments.map { |e| Sync::ClassesJob.new(e, selected_school_year) })
    end

    def fetch_establishments!
      @mapper.establishments_in_responsibility_and_delegated.each { |e| Sync::EstablishmentJob.perform_now(e) }
    end

    def auth_hash
      request.env["omniauth.auth"]
    end

    def add_auth_breadcrumb(data:, message:)
      Sentry.add_breadcrumb(
        Sentry::Breadcrumb.new(
          category: "auth",
          data: data,
          message: message
        )
      )
    end

    def inflate_user
      User.transaction do
        @user = User.from_oidc(auth_hash)
        @user.save!
      rescue ActiveRecord::RecordInvalid
        @user = merge_user_attributes
      end
    end

    def merge_user_attributes
      existing_user = User.find_by(email: @user.email, provider: @user.provider)
      existing_user.update!(
        token: auth_hash["credentials"]["token"],
        uid: auth_hash["uid"],
        name: auth_hash["info"]["name"],
        oidc_attributes: auth_hash
      )
      log_merge_event
      existing_user
    end

    def log_merge_event
      Sentry.capture_exception(
        UserMailDuplicateError.new(
          "Merged user attributes #{auth_hash} for email #{@user.email} and provider #{@user.provider} \
          due to unicity constraint"
        )
      )
    end
  end
end
# rubocop:enable Metrics/ClassLength
