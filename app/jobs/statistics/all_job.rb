# frozen_string_literal: true

module Statistics
  class AllJob < ApplicationJob
    def perform(start_year = SchoolYear.current.start_year)
      Statistics.create_for_year(start_year)
      # Statistics::AcademyJob.perform_now(start_year)
      # Statistics::BopJob.perform_now(start_year)
      # Statistics::EstablishmentJob.perform_now(start_year)
      # Statistics::GlobalJob.perform_now(start_year)
    end
  end
end
