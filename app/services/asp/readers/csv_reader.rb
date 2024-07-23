# frozen_string_literal: true

module ASP
  module Readers
    class CSVReader < Base
      attr_reader :csv

      ASP_CSV_OPTIONS = {
        headers: true,
        col_sep: ";",
        encoding: "ISO8859-1"
      }.freeze

      delegate :each, to: :csv

      def initialize(io:, record: nil)
        super

        @csv ||= CSV.parse(io, **parsing_options)
      end

      def process!
        each do |row|
          ASP::PaymentRequest
            .find(request_identifier(row))
            .tap { |request| handle_request(request, row) }
        rescue ActiveRecord::RecordNotFound
          next
        end
      end

      def request_identifier(row)
        row.fields.first
      end

      def parsing_options
        ASP_CSV_OPTIONS
      end
    end
  end
end
