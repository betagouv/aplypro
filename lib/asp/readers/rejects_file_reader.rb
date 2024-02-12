# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class RejectsFileReader
      attr_reader :io

      def initialize(io)
        @io = io.strip
      end

      def process!
        CSV.parse(io, headers: true, col_sep: ";") do |row|
          id = row["Numéro d'enregistrement"]

          payment_request = ASP::PaymentRequest.find(id)

          payment_request.reject!(row.to_h)
        end
      end
    end
  end
end
