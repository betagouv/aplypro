# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class InduEtrangerMapper < FranceMapper
        def localiteetranger
          student.address_line1
        end

        def bureaudistribetranger
          student.address_line2
        end

        def voiepointgeoetranger
          student.address_line2
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
