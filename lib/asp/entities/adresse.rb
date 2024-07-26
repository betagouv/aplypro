# frozen_string_literal: true

module ASP
  module Entities
    class Adresse < Entity
      attribute :codetypeadr, :string
      attribute :codecominsee, :string
      attribute :codeinseepays, :string
      attribute :codepostalcedex, :string

      validates_presence_of %i[
        codetypeadr
        codeinseepays
        codepostalcedex
        codecominsee
      ]

      def fragment(xml)
        xml.codetypeadr(codetypeadr)
        xml.codeinseepays(codeinseepays)
        xml.codepostalcedex(codepostalcedex)
        xml.codecominsee(codecominsee)
      end

      def self.from_payment_request(payment_request)
        if french_address?
          super
        else
          establishment = payment_request.pfmp.establishment

          new(
            codetypeadr: Mappers::AdresseMapper::ABROAD_ADDRESS_TYPE,
            codecominsee: establishment.commune_code,
            codepostalcedex: establishment.postal_code,
            codeinseepays: InseeCodes::FRANCE_INSEE_COUNTRY_CODE
          )
        end
      end

      private

      def french_address?
        InseeCodes.in_france?(codeinseepays)
      end

      def foreign_address?
        !french_address?
      end
    end
  end
end
