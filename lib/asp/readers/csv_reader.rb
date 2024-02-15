# frozen_string_literal: true

module ASP
  module Readers
    class CSVReader < Base
      ASP_CSV_OPTIONS = {
        headers: true,
        col_sep: ";",
        encoding: "ISO8859-1"
      }.freeze

      def process!
        CSV.parse(io, **parsing_options) do |row|
          ASP::PaymentRequest
            .find(request_identifier(row))
            .tap { |request| handle_request(request, row) }
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
