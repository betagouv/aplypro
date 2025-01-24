# frozen_string_literal: true

module ASP
  class ApplicationController < ActionController::Base
    include UserLogger

    layout "application"

    # TODO: Remettre l'authentification !
    before_action :log_user,
                  :set_overrides,
                  :infer_page_title

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

    def infer_page_title(attrs = {})
      key = page_title_key

      return unless I18n.exists?(key)

      title, breadcrumb = extract_title_data(I18n.t(key, deep_interpolation: true, **attrs))

      @page_title = title

      add_breadcrumb(breadcrumb)
    end

    def page_title_key
      ["pages", "titles", "asp", controller_name, action_name].join(".")
    end

    def extract_title_data(data)
      if data.is_a? Hash
        [data[:title], data[:breadcrumb]]
      else
        [data, data]
      end
    end
  end
end
