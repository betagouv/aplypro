# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class InduEtrangerMapper < FranceMapper
        def localiteetranger
          student.address_city
        end

        def bureaudistribetranger
          student.address_postal_code
        end

        def voiepointgeoetranger
          AddressAbbreviator.abbreviate_address_line(
            student.address_line1,
            max_length: Entities::Adresse::InduEtranger::ADRESSE_ATTR_MAX_LENGTH
          )
        end

        def districtetranger
          AddressAbbreviator.abbreviate_address_line(
            student.address_line2,
            max_length: Entities::Adresse::InduEtranger::ADRESSE_ATTR_MAX_LENGTH
          )
        end

        def regionetranger
          AddressAbbreviator.abbreviate_address_line(
            student.address_line2,
            max_length: Entities::Adresse::InduEtranger::ADRESSE_ATTR_MAX_LENGTH
          )
        end
      end
    end
  end
end
