# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class IntegrationsFileReader < CSVReader
      def process!
        @correctable_pfmp_ids = []
        super
        SendCorrectionAdresseJob.perform_later(@correctable_pfmp_ids) if @correctable_pfmp_ids.any?
      end

      def handle_request(request, row)
        request.mark_integrated!(row.to_h)
        @correctable_pfmp_ids << request.pfmp_id if had_recovery?(request.pfmp.student)
      rescue Statesman::TransitionFailedError
        true
      end

      private

      def had_recovery?(student)
        student.pfmps.any? { |pfmp| pfmp.payment_requests.any?(&:recovery?) }
      end
    end
  end
end
