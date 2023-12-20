# frozen_string_literal: true

module ASP
  module Mappers
    class AdresseMapper
      PRINCIPAL_ADDRESS_TYPE = "PRINCIPALE"

      MAPPING = {
        codecominsee: :address_city_insee_code,
        codeinseepays: :address_country_code,
        codepostalcedex: :address_postal_code
      }.freeze

      attr_reader :student

      def initialize(payment)
        @student = payment.student
      end

      MAPPING.each do |name, attr|
        define_method(name) { student[attr] }
      end

      def codetypeadr
        PRINCIPAL_ADDRESS_TYPE
      end
    end
  end
end
