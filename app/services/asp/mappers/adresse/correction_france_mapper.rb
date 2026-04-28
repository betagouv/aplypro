# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class CorrectionFranceMapper < FranceMapper
        EXTENSION_CODE_ABBREVIATIONS_MAP = {
          "BIS" => "B",
          "TER" => "T",
          "QUATER" => "Q",
          "QUINQUIES" => "C"
        }.freeze

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
          EXTENSION_CODE_ABBREVIATIONS_MAP[student.rnvp_data["voieBis"]&.upcase]
        end

        def codetypevoie
          return nil if student.rnvp_data["voieType"].blank?

          result = AddressAbbreviator.abbreviate_road_type(
            student.rnvp_data["voieType"],
            max_length: Entities::Adresse::CorrectionFrance::CODETYPEVOIE_MAX_LENGTH
          )
          return result if result.nil? || result.length <= Entities::Adresse::CorrectionFrance::CODETYPEVOIE_MAX_LENGTH

          # Last resort: strip vowels (e.g. BOUCLE -> BCL) when CSV abbreviation still exceeds 4 chars
          result.gsub(/[AEIOU]/, "").first(Entities::Adresse::CorrectionFrance::CODETYPEVOIE_MAX_LENGTH)
        end

        def cpltdistribution
          voie_bis = student.rnvp_data["voieBis"] if codeextensionvoie.nil?

          [voie_bis, student.rnvp_data["ligne3"]]
            .compact
            .join(" ")
        end

        def codepostalcedex
          student.rnvp_data["codePostal"]
        end

        # Fallback incase RNVP has no codeInsee
        def codecominsee
          insee_code = student.rnvp_data["codeInsee"].presence || student.address_city_insee_code
          InseeExceptionCodes.transform_insee_code(insee_code)
        end
      end
    end
  end
end
