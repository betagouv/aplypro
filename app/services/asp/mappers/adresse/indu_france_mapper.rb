# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class InduFranceMapper < FranceMapper
        def libellevoie
          student.address_line1.presence || student.address_line2
        end

        def cpltdistribution
          student.address_line1.present? ? student.address_line2 : nil
        end
      end
    end
  end
end
