# frozen_string_literal: true

class InseeCodes
  FRANCE_INSEE_COUNTRY_CODE = "99100"

  class << self
    def in_france?(code)
      return false if code.blank?

      InseeCountryCodeMapper.call(code) == FRANCE_INSEE_COUNTRY_CODE
    end
  end
end
