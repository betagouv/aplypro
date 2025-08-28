# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class FranceMapper
        PRINCIPAL_ADDRESS_TYPE = "PRINCIPALE"

        attr_reader :student

        def initialize(payment_request)
          @student = payment_request.student
        end

        def codetypeadr
          PRINCIPAL_ADDRESS_TYPE
        end

        def codeinseepays
          InseeCountryCodeMapper.call(student.address_country_code)
        end

        def codecominsee
          InseeExceptionCodes.transform_insee_code(student.address_city_insee_code)
        end

        def codepostalcedex
          student.address_postal_code
        end
      end
    end
  end
end
