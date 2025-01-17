# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class Etranger < Base
        # NOTE: for students living outside of France we take address attributes from the establishment
        def fragment(xml)
          establishment = payment_request.pfmp.establishment

          raise ASP::Errors::MissingEstablishmentCommuneCodeError if establishment.commune_code.blank?
          raise ASP::Errors::MissingEstablishmentPostalCodeError if establishment.postal_code.blank?

          xml.codetypeadr(Mappers::Adresse::BaseMapper::PRINCIPAL_ADDRESS_TYPE)
          xml.codecominsee(establishment.commune_code)
          xml.codepostalcedex(establishment.postal_code)
          xml.codeinseepays(InseeCodes::FRANCE_INSEE_COUNTRY_CODE)
        end
      end
    end
  end
end
