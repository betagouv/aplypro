# frozen_string_literal: true

module ASP
  class ErrorsDictionary
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
        return :fallback_message if str.nil?

        I18n.t("asp.errors.rejected.returns").each do |key, msg|
          return key if str.squish.match?(/#{msg}/)
        end

        :fallback_message
      end

      def unpaid_definition(code)
        return :fallback_message if code.nil?

        res = UNPAID_DEFINITIONS[code.to_sym]

        return :fallback_message if res.nil?

        res
      end
    end
  end
end
