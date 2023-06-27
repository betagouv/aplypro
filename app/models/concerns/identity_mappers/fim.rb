# frozen_string_literal: true

module IdentityMappers
  class Fim
    attr_accessor :attributes

    FREDURNE_MAPPING = %i[uai type category activity tna_sym tty_code tna_code].freeze

    def initialize(attributes)
      @attributes = attributes
    end

    def parse_rne
      FREDURNE_MAPPING.zip(attributes["FrEduRne"].split("$")).to_h
    end

    def uai
      data = parse_rne

      data[:uai]
    end
  end
end
