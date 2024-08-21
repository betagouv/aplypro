# frozen_string_literal: true

module ASP
  module Entities
    class Adresse < Entity
      attribute :codetypeadr, :string
      attribute :codecominsee, :string
      attribute :codeinseepays, :string
      attribute :codepostalcedex, :string

      attribute :pointremise, :string
      attribute :cpltdistribution, :string

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

      def self.from_payment_request(payment_request) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        if payment_request.student.lives_in_france?
          super
        elsif payment_request.pfmp.in_state?(:rectified)
          new(
            pointremise: payment_request.student.address_line1,
            cpltdistribution: payment_request.student.address_line2,
            codetypeadr: ASP::Mappers::PRINCIPAL_ADDRESS_TYPE,
            codeinseepays: InseeCountryCodeMapper.call(payment_request.student.address_country_code),
            codecominsee: payment_request.student.address_city_insee_code,
            codepostalcedex: payment_request.student.address_postal_code
          )
        else
          establishment = payment_request.pfmp.establishment

          raise ASP::Errors::MissingEstablishmentCommuneCodeError if establishment.commune_code.blank?
          raise ASP::Errors::MissingEstablishmentPostalCodeError if establishment.postal_code.blank?

          new(
            codetypeadr: Mappers::AdresseMapper::ABROAD_ADDRESS_TYPE,
            codecominsee: establishment.commune_code,
            codepostalcedex: establishment.postal_code,
            codeinseepays: InseeCodes::FRANCE_INSEE_COUNTRY_CODE
          )
        end
      end
    end
  end
end
