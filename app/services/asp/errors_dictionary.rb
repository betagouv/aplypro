# frozen_string_literal: true

module ASP
  class ErrorsDictionary
    REJECTED_DEFINITIONS = [
      {
        key: :bank_coordinates_not_found,
        regexp: /Les codes saisis (.*) n existent pas dans le referentiel refdombancaire/
      },
      {
        key: :technical_support,
        regexp: /ro administratif(.*)n'est pas unique/
      },
      {
        key: :payment_coordinates_blocked,
        regexp: /Coord. paiement bloquees/
      },
      {
        key: :inconsistent_address,
        regexp: /Le code saisi (.*) n'existe pas dans le dictionnaire des referentiels/
      }
    ].freeze

    UNPAID_DEFINITIONS = {
      ICO: :previous_bank_rejection,
      IDR: :anomaly_detected,
      INR: :processing_control,
      IPR: :control_anomaly,
      RJT: :payment_difficulty,
      SFR: :fraud_suspicion
    }.freeze

    class << self
      def rejected_definition(str)
        REJECTED_DEFINITIONS.find { |entry| entry[:regexp].match?(str.squish) }
      end

      def unpaid_definition(code)
        return :technical_support if code.nil?

        res = UNPAID_DEFINITIONS[code.to_sym]

        return :technical_support if res.nil?

        res
      end
    end
  end
end
