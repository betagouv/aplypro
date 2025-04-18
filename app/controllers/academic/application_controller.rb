# frozen_string_literal: true

module Academic
  class ApplicationController < ActionController::Base
    include UserLogger
    include PageTitle
    include SelectedSchoolYear

    layout "application"

    before_action :authenticate_academic_user!,
                  :check_selected_academy,
                  except: %i[login logout]

    before_action :log_user,
                  :set_overrides,
                  :infer_page_title

    helper_method :current_user, :selected_academy, :academies, :selected_school_year

    def home
      @establishments_for_academy = Establishment.joins(:classes)
                                                 .where(academy_code: selected_academy,
                                                        "classes.school_year": selected_school_year)
                                                 .distinct
      @nb_schoolings_per_establishments = @establishments_for_academy.left_joins(:schoolings)
                                                                     .group(:uai)
                                                                     .count(:schoolings)
      @amounts_per_establishments = @establishments_for_academy.left_joins(:pfmps)
                                                               .group(:uai)
                                                               .sum(:amount)
    end

    def login
      @inhibit_banner = true
    end

    def logout
      sign_out(current_academic_user)
      reset_session

      redirect_to after_sign_out_path_for(:academic_user)
    end

    protected

    def after_sign_out_path_for(_resource)
      new_academic_user_session_path
    end

    def current_user
      current_academic_user
    end

    def set_overrides
      @inhibit_nav = true
      @inhibit_title = true
      @logout_path = :destroy_academic_user_session
    end

    def selected_academy
      @selected_academy ||= session[:selected_academy]
    end

    def academies
      @academies ||= session[:academy_codes]
    end

    private

    def check_selected_academy
      return unless academic_user_signed_in?

      redirect_to select_academy_academic_users_path(current_user) if selected_academy.nil?
    end
  end
end
