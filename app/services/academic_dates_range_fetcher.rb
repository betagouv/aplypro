# frozen_string_literal: true

# Returns the eligible range that is allowed for establishments to input PFMPs for a given year based on API data
class AcademicDatesRangeFetcher
  BASE_URL = "https://data.education.gouv.fr/api/v2/catalog/datasets/fr-en-calendrier-scolaire"

  class << self
    def call(academy_code, year = SchoolYear.current.start_year)
      cache_key = "academic_dates_range_fetcher/#{academy_code}/#{year}"

      Rails.cache.fetch(cache_key, expires_in: 1.day) do
        fetch_date_range(academy_code, year)
      end
    end

    def fetch_date_range(academy_code, year) # rubocop:disable Metrics/AbcSize
      location = Establishment::ACADEMY_LABELS.fetch(academy_code)

      previous_year = SchoolYear.new(start_year: year - 1).to_s
      current_year = SchoolYear.new(start_year: year).to_s

      records = fetch_summer_vacations_for_location_and_years(location, previous_year, current_year)

      return fallback_school_year_range(academy_code, year) if records.empty?

      previous_year_vacation = find_summer_vacation_for_year(records, previous_year)
      current_year_vacation = find_summer_vacation_for_year(records, current_year)

      return fallback_school_year_range(academy_code, year) if previous_year_vacation.nil? || current_year_vacation.nil?

      start_date = Date.parse(previous_year_vacation[:end_date]) + 1
      end_date = Date.parse(current_year_vacation[:end_date])
      (start_date..end_date)
    rescue Faraday::Error, JSON::ParserError
      fallback_school_year_range(academy_code, year)
    end

    private

    def fallback_school_year_range(academy_code, year)
      school_year_range_exceptions = {
        "43" => Date.new(year, 8, 23), # Mayotte
        "28" => Date.new(year, 8, 16) # La Réunion
      }

      start_date = school_year_range_exceptions.fetch(academy_code, Date.new(year, 9, 1))
      end_date = start_date >> 12
      (start_date..end_date)
    end

    def fetch_summer_vacations_for_location_and_years(location, previous_year, current_year)
      vacation_type = location == "Réunion" ? "Vacances d'Hiver austral" : "Vacances d'Été"
      where_clause = "location=\"#{location}\" AND (annee_scolaire=\"#{previous_year}\" OR " \
                     "annee_scolaire=\"#{current_year}\") AND description=\"#{vacation_type}\" " \
                     "AND population=\"Élèves\""
      query_params = {
        where: where_clause,
        select: "description,start_date,end_date,location,annee_scolaire,zones,population",
        limit: 100
      }

      response = client.get("#{BASE_URL}/records", query_params)
      data = JSON.parse(response.body)
      data["records"] || []
    rescue Faraday::Error, JSON::ParserError
      []
    end

    def find_summer_vacation_for_year(records, school_year)
      year_record = records.find do |record|
        record.dig("record", "fields", "annee_scolaire") == school_year
      end

      return nil if year_record.nil?

      {
        end_date: year_record.dig("record", "fields", "end_date")
      }
    end

    def client
      @client ||= Faraday.new do |f|
        f.adapter Faraday.default_adapter
      end
    end
  end
end
