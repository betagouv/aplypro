# frozen_string_literal: true

module ASP
  module Readers
    class CorrectionAdresseRejectsFileReader < RejectsFileReader
      def handle_request(request, row)
        raise ASP::Errors::CorrectionAdresseRejectedError,
              "Correction adresse rejected for payment request #{request.id}: #{row.to_h}"
      end
    end
  end
end
