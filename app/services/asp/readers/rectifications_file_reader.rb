# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class RectificationsFileReader < Base
      def process!; end

      def find_payment_request!(asp_prestation_dossier_id)
        Pfmp
          .find_by!(asp_prestation_dossier_id: asp_prestation_dossier_id)
          .payment_requests
          .in_state(:integrated)
          .sole
      end
    end
  end
end
