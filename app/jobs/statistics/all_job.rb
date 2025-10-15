# frozen_string_literal: true

module Statistics
  class AllJob < ApplicationJob
    def perform(school_year = SchoolYear.current)
      Statistics.create_for_year(school_year)
      # Statistics::AcademyJob.perform_now(school_year)
      # Statistics::BopJob.perform_now(school_year)
      # Statistics::EstablishmentJob.perform_now(school_year)
      # Statistics::GlobalJob.perform_now(school_year)
    end
  end
end
