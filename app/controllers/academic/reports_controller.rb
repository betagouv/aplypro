# frozen_string_literal: true

module Academic
  class ReportsController < Academic::ApplicationController
    def index
      infer_page_title
      @inhibit_banner = true
      @reports = Report.includes(:school_year).order(created_at: :desc)
    end

    def show
      infer_page_title
      @inhibit_banner = true
      @report = Report.find(params[:id])
      @current_year = @report.school_year.start_year
      @stats = Stats::Main.new(@current_year)

      prepare_statistics_data
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
  end
end
