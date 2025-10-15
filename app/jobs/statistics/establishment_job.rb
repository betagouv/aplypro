# frozen_string_literal: true

module Statistics
  class EstablishmentJob < ApplicationJob
    def perform(school_year = SchoolYear.current)
      Statistics.create_establishment(school_year)
    end
  end
end
