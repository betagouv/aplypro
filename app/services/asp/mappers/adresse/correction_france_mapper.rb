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
          Entities::Adresse::CorrectionFrance::EXTENSION_CODE_ABBREVIATIONS[voie_bis]
        end

        def codetypevoie
          return if voie_type.blank?

          result = AddressAbbreviator.abbreviate_road_type(
            voie_type,
            max_length: Entities::Adresse::CorrectionFrance::CODETYPEVOIE_MAX_LENGTH
          )
          result if result.length <= Entities::Adresse::CorrectionFrance::CODETYPEVOIE_MAX_LENGTH
        end

        def cpltdistribution
          unsupported_voie_address ||
            [fallback_voie_bis, student.rnvp_data["ligne3"].presence].compact.join(" ").presence
        end

        def codepostalcedex
          student.rnvp_data["codePostal"]
        end

        def codecominsee
          insee_code = student.rnvp_data["codeInsee"].presence || student.address_city_insee_code
          InseeExceptionCodes.transform_insee_code(insee_code)
        end

        private

        def voie_bis
          student.rnvp_data["voieBis"].presence&.upcase
        end

        def voie_type
          student.rnvp_data["voieType"].presence&.upcase
        end

        def fallback_voie_bis
          voie_bis if codeextensionvoie.nil?
        end

        def unsupported_voie_address
          return unless voie_type.present? && codetypevoie.nil?

          [student.rnvp_data["voieNum"], voie_type, student.rnvp_data["voieDen"]].compact.join(" ")
        end
      end
    end
  end
end
