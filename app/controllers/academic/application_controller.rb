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

    def home; end

    def academic_map
      @establishments_data = establishments_data_from_report

      respond_to do |format|
        format.html { render "academic_map", layout: false }
        format.turbo_stream
      end
    rescue ReportNotFoundError => e
      handle_missing_report_error(e)
    rescue ActiveRecord::QueryAborted, ActiveRecord::StatementInvalid, Timeout::Error => e
      handle_academic_map_error(e)
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

    def handle_academic_map_error(error)
      Rails.logger.error("Academic map loading failed: #{error.message}")

      respond_to do |format|
        format.html { render "academic_map_error", layout: false, status: :service_unavailable }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("academic_map", partial: "academic_map_error") }
      end
    end

    def handle_missing_report_error(error)
      Rails.logger.error("No report available for academic map: #{error.message}")

      respond_to do |format|
        format.html { render "academic_map_missing_report", layout: false, status: :not_found }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("academic_map", partial: "academic_map_missing_report")
        end
      end
    end

    def establishments_data_from_report
      report = current_report
      raise ReportNotFoundError, selected_school_year if report.nil?

      Academic::EstablishmentsReportExtractor
        .new(report, selected_academy, selected_school_year)
        .extract_establishments_data
    end

    def current_report
      @current_report ||= Report.select(:id, :school_year_id, :created_at)
                                .for_school_year(selected_school_year)
                                .latest
    end
  end
end
