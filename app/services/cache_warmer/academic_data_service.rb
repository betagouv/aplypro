# frozen_string_literal: true

module CacheWarmer
  class AcademicDataService
    def self.warm_all
      new.warm_all
    end

    def warm_all
      Rails.logger.info "[CacheWarmer] Starting cache warming..."
      start_time = Time.current

      warm_public_stats_caches
      warm_academic_caches

      duration = Time.current - start_time
      Rails.logger.info "[CacheWarmer] Completed cache warming in #{duration.round(2)}s"
    end

    def warm_public_stats_caches
      Rails.logger.info "[CacheWarmer] Warming public stats caches..."
      current_year = SchoolYear.current.start_year

      warm_indicator_cache("schoolings_per_academy", current_year, Stats::Indicator::Schoolings, :count)
      warm_indicator_cache("amounts_per_academy", current_year, Stats::Indicator::SendableAmounts, :sum)
    end

    def warm_indicator_cache(cache_prefix, year, indicator_class, operation)
      cache_key = "#{cache_prefix}/#{year}"
      warm_cache(cache_key) do
        stats_indicator = indicator_class.new(year)
        academies_data(stats_indicator, operation)
      end
    end

    def warm_academic_caches
      school_years = SchoolYear.all
      academy_codes = Establishment::ACADEMY_LABELS.keys

      academy_codes.each do |academy_code|
        Rails.logger.info "[CacheWarmer] Warming caches for academy #{academy_code}..."

        school_years.each do |school_year|
          warm_map_cache(academy_code, school_year)
        end
      end
    end

    private

    def warm_map_cache(academy_code, school_year)
      establishments = Establishment.joins(:classes)
                                    .where(academy_code: academy_code,
                                           "classes.school_year_id": school_year)
                                    .distinct
      establishment_ids = establishments.pluck(:id)

      return if establishment_ids.empty?

      cache_key = "establishments_data_summary/#{establishment_ids.sort.join('-')}/school_year/#{school_year.id}"
      warm_cache(cache_key) do
        Academic::EstablishmentStatsQuery.new(academy_code, school_year).establishments_data_summary(establishment_ids)
      end
    end

    def warm_cache(cache_key, expires_in: 1.week, &)
      Rails.cache.delete(cache_key)
      Rails.cache.fetch(cache_key, expires_in: expires_in, &)
    end

    def academies_data(stats_indicator, operation_type)
      collection = stats_indicator.with_mef_and_establishment
                                  .where("mefs.ministry": :menj)

      if operation_type == :count
        collection.group("establishments.academy_code").count
      else
        collection.group("establishments.academy_code").sum(:amount)
      end
    end
  end
end
