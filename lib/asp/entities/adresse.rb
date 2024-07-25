# frozen_string_literal: true

module ASP
  module Entities
    class Adresse < Entity
      attribute :codetypeadr, :string
      attribute :codecominsee, :string
      attribute :codeinseepays, :string
      attribute :codepostalcedex, :string
      attribute :localiteetranger, :string
      attribute :bureaudistribetranger, :string

      validates_presence_of %i[
        codetypeadr
        codeinseepays
      ]

      validates :codepostalcedex, :codecominsee, presence: true, if: :french_address?
      validates :bureaudistribetranger, :localiteetranger, presence: true, if: :foreign_address?

      def fragment(xml)
        xml.codetypeadr(codetypeadr)
        xml.codeinseepays(codeinseepays)

        if french_address?
          xml.codepostalcedex(codepostalcedex)
          xml.codecominsee(codecominsee)
        else
          xml.localiteetranger(localiteetranger)
          xml.bureaudistribetranger(bureaudistribetranger)
        end
      end

      def self.from_payment_request(payment_request)
        student = payment_request.schooling.student

        if student.lives_in_france?
          super
        else
          establishment = payment_request.pfmp.establishment

          new(
            codetypeadr: Mappers::AdresseMapper::PRINCIPAL_ADDRESS_TYPE,
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
