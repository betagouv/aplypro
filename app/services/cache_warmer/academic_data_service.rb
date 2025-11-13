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
      current_year = SchoolYear.current.start_year

      warm_indicator_cache(
        "schoolings_per_academy", current_year, Stats::Indicator::Count::Schoolings, :count
      )
    end

    private

    def warm_cache(cache_key, expires_in: 1.week, &)
      Rails.cache.delete(cache_key)
      Rails.cache.fetch(cache_key, expires_in: expires_in, &)
    end
  end
end
