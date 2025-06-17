# frozen_string_literal: true

module ASP
  module Mappers
    class EnregistrementMapper
      attr_reader :schooling, :payment_requests

      def initialize(payment_requests)
        @schooling = payment_requests.first.schooling
        @payment_requests = payment_requests
      end

      def id_enregistrement
        schooling.id
      end

      def id_individu
        schooling.student.asp_individu_id
      end
    end
  end
end
