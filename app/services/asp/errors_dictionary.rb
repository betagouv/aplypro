# frozen_string_literal: true

module ASP
  class ErrorsDictionary
    REJECTED_DEFINITIONS = [
      {
        key: :bank_coordinates_not_found,
        regexp: /Les codes saisis (.*) n existent pas dans le referentiel refdombancaire/
      },
      {
        key: :administrative_number_already_taken,
        regexp: /ro administratif(.*)n'est pas unique/
      },
      {
        key: :payment_coordinates_blocked,
        regexp: /Coord. paiement bloquees/
      }
    ].freeze

    UNPAID_DEFINITIONS = [
      IAL: :payment_failed,
      IAM: :payment_failed,
      ICO: :previous_bank_rejection,
      IDR: :anomaly_detected,
      RJT: :payment_difficulty,
      TR1: :technical_support,
      TR2: :technical_support,
    ].freeze

    class << self
      def rejected_definition(str)
        REJECTED_DEFINITIONS.find { |entry| entry[:regexp].match?(str.squish) }
      end

      def unpaid_definition(code)
        UNPAID_DEFINITIONS[code]
      end
    end
  end
end
