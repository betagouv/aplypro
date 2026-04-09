# frozen_string_literal: true

module ASP
  module Readers
    class CorrectionAdresseIntegrationsFileReader < IntegrationsFileReader
      def handle_request(request, row)
        mismatches = id_mismatches(request, row)
        return if mismatches.empty?

        raise ASP::Errors::CorrectionAdresseIdMismatchError,
              "ID mismatch for payment request #{request.id}: #{mismatches.join(', ')}"
      end

      private

      def id_mismatches(request, row)
        [
          check_id(row, "idIndDoss", request.student.asp_individu_id),
          check_id(row, "idDoss", request.schooling.asp_dossier_id),
          check_id(row, "idPretaDoss", request.pfmp.asp_prestation_dossier_id)
        ].compact
      end

      def check_id(row, key, expected)
        return if row[key] == expected

        "#{key}: expected #{expected}, got #{row[key]}"
      end
    end
  end
end
