# frozen_string_literal: true

module Statistics
  class AcademyJob < ApplicationJob
    def perform(school_year = SchoolYear.current)
      Statistics.create_academy(school_year)
    end
  end
end
