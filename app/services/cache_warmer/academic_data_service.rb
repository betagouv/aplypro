# frozen_string_literal: true

module CacheWarmer
  class AcademicDataService
    def self.warm_all
      new.warm_all
    end

    def warm_all
      warm_public_stats_caches
    end

    def warm_public_stats_caches
      current_report = Report
                       .select(:id, :school_year_id, :created_at)
                       .for_school_year(SchoolYear.current)
                       .ordered
                       .first

      return unless current_report

      extractor = Reports::BaseExtractor.new(current_report)
      extractor.extract(:menj_academies_data, :establishments_data)
    end
  end
end
