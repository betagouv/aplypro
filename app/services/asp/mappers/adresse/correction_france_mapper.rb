# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class CorrectionFranceMapper < FranceMapper
        def numerovoie
          student.rnvp_data["voieNum"].presence
        end

        def libellevoie
          student.rnvp_data["voieDen"]
        end

        def codeextensionvoie
          student.rnvp_data["voieBis"].presence
        end

        def codetypevoie
          student.rnvp_data["voieType"].presence
        end

        def cpltdistribution
          student.rnvp_data["ligne5"].presence
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
