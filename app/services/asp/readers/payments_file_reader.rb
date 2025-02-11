# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class PaymentsFileReader < Base
      attr_reader :xml, :records

      class Node
        attr_reader :node

        def initialize(node)
          @node = node
        end

        def state
          node.search("ETATPAIEMENT").text
        end

        def to_h
          Hash.from_xml(node.to_s)
        end

        def asp_prestation_dossier_id
          node.search("LISTEPRESTADOSS/PRESTADOSS/IDPRESTADOSS").first.text
        end
      end

      def initialize(io:, record:)
        super

        @xml = Nokogiri::XML(io)
        @records = xml.search("LISTEPAIEMENT/PAIEMENT")
      end

      def each
        records.each do |record|
          yield Node.new(record)
        end
      end

      def process! # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        each do |node|
          request =
            find_payment_request!(node.asp_prestation_dossier_id)
          case node.state
          when "PAYE"
            request.mark_paid!(node.to_h, record)
          when "INVALIDE"
            request.mark_unpaid!(node.to_h, record)
          else
            raise "unknown payment state: #{state}"
          end
        rescue ActiveRecord::RecordNotFound => e
          Sentry.capture_exception(
            ASP::Errors::ReadingFileError.new(
              "Payment file reading failed for asp_prestation_dossier_id: #{node.asp_prestation_dossier_id} " \
              "with message #{e.message}, Node contents: #{node.to_h}"
            )
          )
          raise e
        end
      end

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
