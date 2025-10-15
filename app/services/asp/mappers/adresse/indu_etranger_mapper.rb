# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class InduEtrangerMapper < FranceMapper
        def localiteetranger
          AddressAbbreviator.abbreviate(
            student.address_city,
            max_length: Entities::Adresse::InduEtranger::ADRESSE_ATTR_MAX_LENGTH
          )
        end

        def bureaudistribetranger
          AddressAbbreviator.abbreviate(
            student.address_postal_code,
            max_length: Entities::Adresse::InduEtranger::ADRESSE_ATTR_MAX_LENGTH
          )
        end

        def voiepointgeoetranger
          AddressAbbreviator.abbreviate(
            student.address_line1,
            max_length: Entities::Adresse::InduEtranger::ADRESSE_ATTR_MAX_LENGTH
          )
        end

        def districtetranger
          AddressAbbreviator.abbreviate(
            student.address_line2,
            max_length: Entities::Adresse::InduEtranger::ADRESSE_ATTR_MAX_LENGTH
          )
        end

        def regionetranger
          AddressAbbreviator.abbreviate(
            student.address_line2,
            max_length: Entities::Adresse::InduEtranger::ADRESSE_ATTR_MAX_LENGTH
          )
        end
      end
    end
  end
end
