# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class CorrectionFranceMapper < FranceMapper
        def numerovoie
          student.rnvp_data["voieNum"].presence
        end

        def libellevoie
          AddressAbbreviator.abbreviate_address_line(
            student.rnvp_data["voieDen"],
            max_length: Entities::Adresse::InduFrance::LIBELLEVOIE_MAX_LENGTH
          )
        end

        def codeextensionvoie
          student.rnvp_data["voieBis"].presence
        end

        def codetypevoie
          return nil if student.rnvp_data["voieType"].blank?

          AddressAbbreviator.abbreviate_road_type(
            student.rnvp_data["voieType"],
            max_length: Entities::Adresse::CorrectionFrance::CODETYPEVOIE_MAX_LENGTH
          )
        end

        def cpltdistribution
          student.rnvp_data["ligne3"].presence
        end

        def codepostalcedex
          student.rnvp_data["codePostal"]
        end

        def codecominsee
          InseeExceptionCodes.transform_insee_code(student.rnvp_data["codeInsee"])
        end
      end
    end
  end
end
