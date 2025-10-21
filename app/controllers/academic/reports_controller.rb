# frozen_string_literal: true

module Academic
  class ReportsController < Academic::ApplicationController
    include Zipline

    before_action :set_report_context, only: %i[show global export]

    def index
      infer_page_title
      @inhibit_banner = true
      @inhibit_breadcrumb = true
      @school_years = SchoolYear.order(start_year: :desc)
      @selected_school_year_id = params[:school_year_id]

      @reports = Report.includes(:school_year).order(created_at: :desc)
      @reports = @reports.where(school_year_id: @selected_school_year_id) if @selected_school_year_id.present?
    end

    def show
      prepare_statistics_data
    end

    def global
      return redirect_unauthorized unless current_user.admin?

      prepare_global_statistics_data
    end

    def export
      return redirect_unauthorized unless current_user.admin?

      zipline(export_files, export_filename)
    end

    private

    def set_report_context
      infer_page_title
      @inhibit_banner = true
      @inhibit_breadcrumb = true
      @report = Report.find(params[:id])
      @current_year = @report.school_year.start_year
      @stats = Stats::Main.new(@current_year)

      @comparable_reports = Report.where(school_year: @report.school_year)
                                  .where(created_at: ...@report.created_at)
                                  .order(created_at: :desc)

      @comparison_report = determine_comparison_report
    end

    def redirect_unauthorized
      redirect_to academic_report_path(params[:id]), alert: t("academic.reports.export.unauthorized")
    end

    def prepare_statistics_data
      @academy_stats = academy_statistics
      set_report_data
      @establishments_data = filtered_establishments_data_from_report
      @academy_stats_progressions = calculate_academy_progressions
    end

    def prepare_global_statistics_data
      set_report_data
      @establishments_data = @report.data["establishments_data"]
      @global_stats = Reports::StatsExtractor.extract_global_stats(@report)
      @global_stats_progressions = calculate_global_progressions
    end

    def set_report_data
      @global_data = @report.data["global_data"]
      @bops_data = @report.data["bops_data"]
      @menj_academies_data = @report.data["menj_academies_data"]
      @indicators_metadata = @stats.indicators_with_metadata
    end

    def academy_statistics
      stats_builder.calculate_academy_stats(@report)
    end

    def filtered_establishments_data_from_report
      full_data = @report.data["establishments_data"]
      stats_builder.filter_establishments_data(full_data)
    end

    def calculate_academy_progressions
      return {} unless @comparison_report

      Academic::ReportsProgressionComparator.compare(@report, @comparison_report, selected_academy)
    end

    def calculate_global_progressions
      return {} unless @comparison_report

      Reports::GlobalProgressionComparator.compare(@report, @comparison_report)
    end

    def determine_comparison_report
      if params[:comparison_report_id].present?
        @comparable_reports.find_by(id: params[:comparison_report_id])
      else
        @comparable_reports.first
      end
    end

    def stats_builder
      @stats_builder ||= Academic::StatsDataBuilder.new(selected_academy, @report.school_year)
    end

    def export_files
      csv_exporter = Reports::CSVExporter.new(@report)
      csv_exporter.csv_files.map do |filename, content|
        [StringIO.new(content), filename]
      end
    end

    def export_filename
      year = @report.school_year.start_year
      date = @report.created_at.strftime("%Y%m%d")
      "aplypro_rapport_#{@report.id}_annee-scol#{year}_date#{date}.zip"
    end
  end
end
