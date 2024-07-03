# frozen_string_literal: true

class SchoolYearSeeder
  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    logger.info "[seeds] inserting school years..."

    SchoolYear.delete_all

    SchoolYear.create(start_year: 2023)
    SchoolYear.create(start_year: 2024)

    logger.info "[seeds] done inserting #{SchoolYear.count} school years."
  end
end
