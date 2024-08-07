# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class IntegrationsFileReader < CSVReader
      def handle_request(request, row)
        request.mark_integrated!(row.to_h)
      rescue Statesman::TransitionFailedError
        true
      end
    end
  end
end
