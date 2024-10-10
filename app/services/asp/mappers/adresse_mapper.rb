# frozen_string_literal: true

module ASP
  module Mappers
    class AdresseMapper
      PRINCIPAL_ADDRESS_TYPE = "PRINCIPALE"
      ABROAD_ADDRESS_TYPE = "ADMIN" # From ASP Doc (Apparently not supported by ASP!)

      MAPPING = {
        codecominsee: :address_city_insee_code,
        codepostalcedex: :address_postal_code
      }.freeze

      attr_reader :student

      def initialize(payment_request)
        @student = payment_request.student
      end

      MAPPING.each do |name, attr|
        define_method(name) { student[attr] }
      end

      def codetypeadr
        PRINCIPAL_ADDRESS_TYPE
      end

      def codeinseepays
        InseeCountryCodeMapper.call(student.address_country_code)
      end
    end
  end
end
