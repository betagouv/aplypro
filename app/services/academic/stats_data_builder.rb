# frozen_string_literal: true

module Academic
  class StatsDataBuilder
    def initialize(academy_code, school_year)
      @academy_code = academy_code
      @school_year = school_year
    end

    def current_academy_establishments
      Establishment.joins(:classes)
                   .where(academy_code: @academy_code,
                          "classes.school_year_id": @school_year)
                   .distinct
    end

    def filter_establishments_data(full_data)
      titles = full_data.first
      establishment_rows = full_data[1..]

      academy_establishments = current_academy_establishments.pluck(:uai)

      filtered_rows = establishment_rows.select do |row|
        uai = row[0]
        academy_establishments.include?(uai)
      end

      [titles, *filtered_rows]
    end
  end
end
