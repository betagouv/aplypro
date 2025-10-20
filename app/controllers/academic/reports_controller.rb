# frozen_string_literal: true

module Academic
  class ReportsController < Academic::ApplicationController
    include Zipline

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
      infer_page_title
      @inhibit_banner = true
      @inhibit_breadcrumb = true
      @report = Report.find(params[:id])
      @current_year = @report.school_year.start_year
      @stats = Stats::Main.new(@current_year)

      prepare_statistics_data
    end

    def export
      @report = Report.find(params[:id])

      unless current_user.admin?
        redirect_to academic_report_path(@report), alert: t(".unauthorized")
        return
      end

      zipline(export_files, export_filename)
    end

    private

    def prepare_statistics_data
      @academy_stats = academy_statistics
      @global_data = @report.data["global_data"]
      @bops_data = @report.data["bops_data"]
      @menj_academies_data = @report.data["menj_academies_data"]
      @establishments_data = filtered_establishments_data_from_report
      @academy_stats_progressions = calculate_progressions
      @indicators_metadata = @stats.indicators_with_metadata
    end

    def academy_statistics
      cache_key = "academy_stats/#{selected_academy}/report/#{@report.id}/school_year/#{@report.school_year.id}"

      Rails.cache.fetch(cache_key, expires_in: 1.week) do
        stats_builder.calculate_academy_stats(@report)
      end
    end

    def filtered_establishments_data_from_report
      cache_key = "filtered_establishments_data/#{selected_academy}/report/#{@report.id}/" \
                  "school_year/#{@report.school_year.id}"

      Rails.cache.fetch(cache_key, expires_in: 1.week) do
        full_data = @report.data["establishments_data"]
        stats_builder.filter_establishments_data(full_data)
      end
    end

    def calculate_progressions
      cache_key = "academy_stats_progressions/#{selected_academy}/report/#{@report.id}/" \
                  "school_year/#{@report.school_year.id}"

      Rails.cache.fetch(cache_key, expires_in: 1.week) do
        stats_builder.calculate_progressions(@report, @academy_stats)
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
