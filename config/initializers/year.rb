# frozen_string_literal: true

module Aplypro
  SCHOOL_YEAR = ENV.fetch("APLYPRO_SCHOOL_YEAR").to_i

  DEFAULT_SCHOOL_YEAR_START = Date.new(SCHOOL_YEAR, 9, 1)
end
