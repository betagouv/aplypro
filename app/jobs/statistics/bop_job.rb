# frozen_string_literal: true

module Statistics
  class BopJob < ApplicationJob
    def perform(school_year = SchoolYear.current)
      Statistics.create_bop(school_year)
    end
  end
end
