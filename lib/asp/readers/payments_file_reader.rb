# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class PaymentsFileReader < Base
      def process!
        xml = Nokogiri::XML(io)

        xml.search("LISTEPAIEMENT/PAIEMENT").each do |payment|
          state = (payment / "ETATPAIEMENT").text

          payment.search("LISTEPRESTADOSS/PRESTADOSS").each do |file|
            request = find_request!(file)

            case state
            when "PAYE"
              request.mark_paid!
            when "INVALIDE"
              request.mark_unpaid!
            else
              raise "unsure how to handle reason: #{state}"
            end
          end
        end
      end

      def find_request!(node)
        id = (node / "IDPRESTADOSS").text

        Pfmp
          .find_by!(asp_prestation_dossier_id: id)
          .payment_requests
          .in_state(:integrated)
          .first
      end
    end
  end
end
