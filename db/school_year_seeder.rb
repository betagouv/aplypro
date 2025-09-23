# frozen_string_literal: true

class SchoolYearSeeder
  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

    SchoolYear.find_or_create_by(start_year: 2023)
    SchoolYear.find_or_create_by(start_year: 2024)
    SchoolYear.find_or_create_by(start_year: 2025)

    logger.info "[seeds] upserted #{SchoolYear.count} school years."
  end
end
