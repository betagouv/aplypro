# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class RejectsFileReader < CSVReader
      def handle_request(request, row)
        request.reject!(row.to_h)
      end
    end
  end
end
