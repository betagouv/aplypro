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
          student.address_line1.split(" | ").join(" ")
        end

        def districtetranger
          student.address_line2
        end

        def regionetranger
          student.address_line2
        end
      end
    end
  end
end
