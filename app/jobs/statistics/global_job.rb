# frozen_string_literal: true

module Statistics
  class GlobalJob < ApplicationJob
    def perform(school_year = SchoolYear.current)
      Statistics.create_global(school_year)
    end
  end
end
