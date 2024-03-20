# frozen_string_literal: true

module Aplypro
  SCHOOL_YEAR = ENV.fetch("APLYPRO_SCHOOL_YEAR").to_i

  SCHOOL_YEAR_START = Date.new(SCHOOL_YEAR, 9, 1)

  SCHOOL_YEAR_RANGE = (SCHOOL_YEAR_START...SCHOOL_YEAR_START >> 12)
end
