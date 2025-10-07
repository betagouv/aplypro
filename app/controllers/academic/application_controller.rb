# frozen_string_literal: true

module Academic
  class ApplicationController < ActionController::Base
    include UserLogger
    include PageTitle
    include SelectedSchoolYear

    layout "academic"

    before_action :authenticate_academic_user!,
                  :check_selected_academy,
                  except: %i[login logout set_selected_academy]

    before_action :log_user,
                  :set_overrides,
                  :infer_page_title

    helper_method :current_user, :selected_academy, :authorised_academy_codes, :selected_school_year

    def home
      establishments = Establishment.joins(:classes)
                                    .where(academy_code: selected_academy,
                                           "classes.school_year_id": selected_school_year)
                                    .distinct

      @establishments_data = establishments_data_summary(establishments.pluck(:id))
    end

    def academic_map
      establishments = Establishment.joins(:classes)
                                    .where(academy_code: selected_academy,
                                           "classes.school_year_id": selected_school_year)
                                    .distinct

      @establishments_data = establishments_data_summary(establishments.pluck(:id))

      respond_to do |format|
        format.html { render partial: "academic_map", layout: false }
        format.turbo_stream
      end
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
      @inhibit_nav = false
      @inhibit_title = true
      @logout_path = :destroy_academic_user_session
    end

    def selected_academy
      @selected_academy ||= session[:selected_academy]
    end

    def authorised_academy_codes
      @authorised_academy_codes ||= session[:academy_codes]
    end

    def check_selected_academy
      return unless selected_academy.nil?

      redirect_to select_academy_academic_users_path(current_user)
    end

    private

    def establishments_data_summary(ids)
      cache_key = "establishments_data_summary/#{ids.sort.join('-')}/school_year/#{selected_school_year}"

      Rails.cache.fetch(cache_key, expires_in: 1.week) do
        Academic::StatsDataBuilder.new(selected_academy, selected_school_year).establishments_data_summary(ids)
      end
    end
  end
end
