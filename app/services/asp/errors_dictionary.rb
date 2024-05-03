# frozen_string_literal: true

module ASP
  class ErrorsDictionary
    DEFINITIONS = [
      {
        key: :bank_coordinates_not_found,
        regexp: /Les codes saisis (.*) n existent pas dans le referentiel refdombancaire/
      },
      {
        key: :administrative_number_already_taken,
        regexp: /ro administratif(.*)n'est pas unique/
      }
    ].freeze

    class << self
      def definition(str)
        DEFINITIONS.find { |entry| entry[:regexp].match?(str.squish) }
      end
    end
  end
end
