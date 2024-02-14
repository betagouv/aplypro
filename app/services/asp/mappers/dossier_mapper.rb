# frozen_string_literal: true

module ASP
  module Mappers
    class DossierMapper
      include Constants

      MAPPING = {
        numadm: :attributive_decision_number
      }.freeze

      attr_reader :schooling

      def initialize(payment_request)
        @schooling = payment_request.payment.schooling
      end

      MAPPING.each do |name, attr|
        define_method(name) { schooling.send(attr) }
      end

      def codedispositif
        CODE_DISPOSITIF
      end
    end
  end
end
