# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class IntegrationsFileReader
      attr_reader :io

      def initialize(io)
        @io = io.strip
      end

      def process!
        CSV.parse(io, headers: true, col_sep: ";", encoding: "ISO8859-1") do |row|
          id = row["Numero enregistrement"]

          request = ASP::PaymentRequest.find(id)

          request.mark_integrated!(row.to_h)

          # student.payments.in_state(:processing).each(&:fail!)
        end
      end
    end
  end
end
