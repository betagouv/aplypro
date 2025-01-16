# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class Indu < Base
        attribute :pointremise, :string
        attribute :cpltdistribution, :string

        validates_presence_of %i[
          pointremise
          cpltdistribution
        ]

        def fragment(xml)
          xml.pointremise(pointremise)
          xml.cpltdistribution(cpltdistribution)

          xml.codetypeadr(ASP::Mappers::Adresse::BaseMapper::PRINCIPAL_ADDRESS_TYPE)
          xml.codeinseepays(InseeCountryCodeMapper.call(payment_request.student.address_country_code))
          xml.codepostalcedex(payment_request.student.address_postal_code)
          xml.codecominsee(payment_request.student.address_city_insee_code)
        end
      end
    end
  end
end
