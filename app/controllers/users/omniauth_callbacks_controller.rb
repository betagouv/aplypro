# frozen_string_literal: true

module Users
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
        EstablishmentUser.create!(user: @user, establishment: e, role: :dir)
      end

      @mapper.authorised_establishments_for(@user.email).each do |e|
        EstablishmentUser.create!(user: @user, establishment: e, role: :authorised)
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
      roles = @user.establishment_users

      if roles.one?
        @user.update!(establishment: roles.first.establishment)

        redirect_to classes_path, notice: t("auth.success")
      else
        @user.establishments.each(&:fetch_data!)

        render action: :select_etab
      end
    end

    def fetch_students!
      jobs = @mapper.establishments.map { |e| FetchStudentsJob.new(e) }

      ActiveJob.perform_all_later(jobs)
    end

    def auth_hash
      request.env["omniauth.auth"]
    end
  end
end
