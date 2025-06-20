# frozen_string_literal: true

module ASP
  module Mappers
    class EnregistrementMapper
      attr_reader :payment_requests

      def initialize(payment_requests)
        @payment_requests = payment_requests
      end

      def id_enregistrement
        payment_requests.first.id
      end

      def id_individu
        payment_requests.first.student.asp_individu_id
      end
    end
  end
end
