# frozen_string_literal: true

class SchoolYearRange < ApplicationRecord
  EXCEPTIONS = %w[0 28 43].freeze

  belongs_to :school_year

  validates :academy_code, presence: true

  validates :end_date,
            comparison: { greater_than_or_equal_to: :start_date },
            if: -> { start_date && end_date }

  # TODO: Ajouter une validation qui vérifie que pour l'académie et l'année insérée,
  # la date de début est un jour après la date de fin de l'année-1

  class << self
    def range(school_year = SchoolYear.current, academy_code = "0")
      academy_code = "0" unless EXCEPTIONS.include?(academy_code)

      s_y_range = SchoolYearRange.find_by(school_year: school_year, academy_code: academy_code)

      if s_y_range.present?
        (s_y_range.start_date..s_y_range.end_date)
      else
        (Date.new(school_year.start_year, 9, 1)..Date.new(school_year.end_year, 8, 31))
      end
    end
  end
end
