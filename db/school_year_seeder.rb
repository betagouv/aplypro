# frozen_string_literal: true

class SchoolYearSeeder
  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    logger.info "[seeds] upserting school years..."

    SchoolYear.find_or_create_by(start_year: 2023)
    SchoolYear.find_or_create_by(start_year: 2024)

    logger.info "[seeds] done upserting #{SchoolYear.count} school years."
  end
end
