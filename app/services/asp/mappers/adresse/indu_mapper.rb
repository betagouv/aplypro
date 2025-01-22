# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class InduMapper < FranceMapper
        # Max 38 characters
        def pointremise
          student.address_line1.slice(0, 38)
        end

        # Max 38 characters
        def cpltdistribution
          student.address_line2&.slice(0, 38)
        end
      end
    end
  end
end
