# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class RejectsFileReader < CSVReader
      # @emaildoc
      #   Bonjour,
      #   le fichier des rejets est encodé en ANSI.
      #   Il ne faut surtout pas le traité en UTF8.
      def handle_input(raw)
        str = raw.force_encoding("ISO-8859-1").encode("UTF-8")

        super(str)
      end

      def handle_request(request, row)
        request.mark_rejected!(row.to_h)
      rescue Statesman::TransitionFailedError
        true
      end
    end
  end
end
