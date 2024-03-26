# frozen_string_literal: true

module ASP
  class ApplicationController < ActionController::Base
    layout "application"

    before_action :authenticate_asp_user!, except: :login
    before_action :set_overrides

    helper_method :current_user, :current_establishment

    def login; end

    def logout
      sign_out(current_asp_user)

      redirect_to after_sign_out_path_for(:asp_user)
    end

    protected

    def after_sign_out_path_for(_resource)
      new_asp_user_session_path
    end

    def current_user
      current_asp_user
    end

    def current_establishment
      nil
    end

    def set_overrides
      @inhibit_nav = true
      @logout_path = :destroy_asp_user_session
    end
  end
end
