# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class PaymentsFileReader < Base
      def process!
        xml = Nokogiri::XML(io)

        xml
          .search("LISTEPAIEMENT/PAIEMENT")
          .each { |node| handle_payment_node(node) }
      end

      private

      def handle_payment_node(node)
        state = (node / "ETATPAIEMENT").text
        row = Hash.from_xml(node.to_s)

        node.search("LISTEPRESTADOSS/PRESTADOSS").each do |file|
          request = find_payment_request!(file)

          case state
          when "PAYE"
            request.mark_paid!(row, record)
          when "INVALIDE"
            request.mark_unpaid!(row, record)
          else
            raise "unknown payment state: #{state}"
          end
        end
      end

      def find_payment_request!(node)
        id = (node / "IDPRESTADOSS").text

        Pfmp
          .find_by!(asp_prestation_dossier_id: id)
          .payment_requests
          .in_state(:integrated)
          .sole
      end
    end
  end
end
