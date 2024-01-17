# frozen_string_literal: true

module ASP
  module Entities
    class CoordonneesPaiement < Entity
      CODE_MODE_REGLEMENT_IBAN = "135"
      CODE_TYPE_COORDONNEE_PAIEMENT_PRINCIPALE = "PRINCIPALE"

      attribute :codetypecoordpaie, :string
      attribute :codemodereglement, :string
      attribute :intitdest, :string
      attribute :codeisopays, :string
      attribute :zonebban, :string
      attribute :clecontrole, :string
      attribute :bic, :string

      validates_presence_of %i[codetypecoordpaie
                               codemodereglement
                               intitdest
                               codeisopays
                               zonebban
                               clecontrole
                               bic]

      def fragment(builder)
        builder.coordpaie do |xml|
          xml.codetypecoordpaie(codetypecoordpaie)
          xml.codemodereglement(codemodereglement)
          xml.intitdest(intitdest)

          iban(xml)
        end
      end

      private

      def codetypecoordpaie
        CODE_TYPE_COORDONNEE_PAIEMENT_PRINCIPALE
      end

      def codemodereglement
        CODE_MODE_REGLEMENT_IBAN
      end

      def iban(xml)
        xml.iban do
          xml.bic(bic)
          xml.clecontrol(clecontrole)
          xml.zonebban(zonebban)
          xml.codeisopays(codeisopays)
        end
      end
    end
  end
end
