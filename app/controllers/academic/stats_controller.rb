# frozen_string_literal: true

module Academic
  class StatsController < Academic::ApplicationController
    def index
      @inhibit_banner = true
      @current_year = selected_school_year.start_year
      @report = find_report
      @stats = Stats::Main.new(@current_year)

      prepare_statistics_data if @report
    end

    private

    def find_report
      report_id = params[:report_id]
      return Report.find(report_id) if report_id.present?

      Report.latest
    end

    def prepare_statistics_data
      @academy_stats = academy_statistics
      @global_data = @report.data["global_data"]
      @bops_data = @report.data["bops_data"]
      @menj_academies_data = @report.data["menj_academies_data"]
      @establishments_data = filtered_establishments_data_from_report
      @academy_stats_progressions = calculate_progressions
    end

    def academy_statistics
      cache_key = "academy_stats/#{selected_academy}/report/#{@report.id}/school_year/#{selected_school_year.id}"

      Rails.cache.fetch(cache_key, expires_in: 1.week) do
        stats_builder.calculate_academy_stats(@report)
      end
    end

    def filtered_establishments_data_from_report
      cache_key = "filtered_establishments_data/#{selected_academy}/report/#{@report.id}/" \
                  "school_year/#{selected_school_year.id}"

      Rails.cache.fetch(cache_key, expires_in: 1.week) do
        full_data = @report.data["establishments_data"]
        stats_builder.filter_establishments_data(full_data)
      end
    end

    def calculate_progressions
      cache_key = "academy_stats_progressions/#{selected_academy}/report/#{@report.id}/" \
                  "school_year/#{selected_school_year.id}"

      Rails.cache.fetch(cache_key, expires_in: 1.week) do
        stats_builder.calculate_progressions(@report, @academy_stats)
      end
    end

    def stats_builder
      @stats_builder ||= Academic::StatsDataBuilder.new(selected_academy, selected_school_year)
    end
  end
end
