# frozen_string_literal: true

module ASP
  module Mappers
    class DossierMapper
      MAPPING = {
        numadm: :attributive_decision_number
      }.freeze

      attr_reader :schooling

      def initialize(payment)
        @schooling = payment.schooling
      end

      MAPPING.each do |name, attr|
        define_method(name) { schooling.send(attr) }
      end
    end
  end
end
