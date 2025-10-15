# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class InduFranceMapper < FranceMapper
        def libellevoie
          address_line = student.address_line1.presence || student.address_line2
          AddressAbbreviator.abbreviate(
            address_line,
            max_length: Entities::Adresse::InduFrance::LIBELLEVOIE_MAX_LENGTH
          )
        end

        def cpltdistribution
          return nil if student.address_line1.blank?

          AddressAbbreviator.abbreviate(
            student.address_line2,
            max_length: Entities::Adresse::InduFrance::ADRESSE_ATTR_MAX_LENGTH
          )
        end
      end
    end
  end
end
