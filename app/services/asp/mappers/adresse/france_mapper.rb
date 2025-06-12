# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class FranceMapper
        PRINCIPAL_ADDRESS_TYPE = "PRINCIPALE"

        MAPPING = {
          codecominsee: :address_city_insee_code,
          codepostalcedex: :address_postal_code
        }.freeze

        attr_reader :student

        def initialize(schooling)
          @student = schooling.student
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
end
