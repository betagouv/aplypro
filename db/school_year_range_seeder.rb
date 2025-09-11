# frozen_string_literal: true

class SchoolYearRangeSeeder
  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

    s_y_2023 = SchoolYear.find_by(start_year: 2023)
    s_y_2024 = SchoolYear.find_by(start_year: 2024)

    # Métropole : 0
    SchoolYearRange.find_or_create_by(school_year: s_y_2023, academy_code: 0, start_date: Date.parse("2023-09-04"), end_date: Date.parse("2024-09-01"))
    SchoolYearRange.find_or_create_by(school_year: s_y_2024, academy_code: 0, start_date: Date.parse("2024-09-02"), end_date: Date.parse("2025-08-31"))

    # La Réunion : 28
    SchoolYearRange.find_or_create_by(school_year: s_y_2023, academy_code: 28, start_date: Date.parse("2023-08-17"), end_date: Date.parse("2024-08-18"))
    SchoolYearRange.find_or_create_by(school_year: s_y_2024, academy_code: 28, start_date: Date.parse("2024-08-19"), end_date: Date.parse("2025-08-18"))

    # Mayotte : 43
    SchoolYearRange.find_or_create_by(school_year: s_y_2023, academy_code: 43, start_date: Date.parse("2023-08-23"), end_date: Date.parse("2024-08-25"))
    SchoolYearRange.find_or_create_by(school_year: s_y_2024, academy_code: 43, start_date: Date.parse("2024-08-26"), end_date: Date.parse("2025-08-24"))

    logger.info "[seeds] upserted #{SchoolYearRange.count} school year ranges."
  end
end
