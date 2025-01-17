# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class BaseMapper
        PRINCIPAL_ADDRESS_TYPE = "PRINCIPALE"

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

        # Max 38 characters
        def pointremise
          student.address_line1.slice(0, 38)
        end

        # Max 38 characters
        def cpltdistribution
          student.address_line2&.slice(0, 38)
        end
      end
    end
  end
end
