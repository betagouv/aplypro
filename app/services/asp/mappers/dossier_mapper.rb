# frozen_string_literal: true

module ASP
  module Mappers
    class DossierMapper
      include Constants

      MAPPING = {
        numadm: :attributive_decision_number,
        id_dossier: :asp_dossier_id
      }.freeze

      attr_reader :schooling, :payment_requests

      def initialize(payment_requests)
        @schooling = payment_requests.first.schooling
        @payment_requests = payment_requests
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
