# frozen_string_literal: true

module Academic
  class ApplicationController < ActionController::Base
    include UserLogger
    include PageTitle

    layout "application"

    before_action :authenticate_academic_user!, except: :login
    before_action :log_user,
                  :set_overrides,
                  :infer_page_title

    helper_method :current_user, :current_establishment

    def home; end

    def login; end

    def logout
      sign_out(current_academic_user)

      redirect_to after_sign_out_path_for(:academic_user)
    end

    protected

    def after_sign_out_path_for(_resource)
      new_academic_user_session_path
    end

    def current_user
      current_academic_user
    end

    def current_establishment
      nil
    end

    def set_overrides
      @inhibit_nav = true
      @logout_path = :destroy_academic_user_session
    end
  end
end
