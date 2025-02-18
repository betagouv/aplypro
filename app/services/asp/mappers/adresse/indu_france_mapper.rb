# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class InduFranceMapper < FranceMapper
        def pointremise
          student.address_line1
        end

        def cpltdistribution
          student.address_line2
        end
      end
    end
  end
end
