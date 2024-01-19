# frozen_string_literal: true

module ASP
  module Entities
    class PersPhysique < Entity
      attribute :titre, :string
      attribute :nomusage, :string
      attribute :nomnaissance, :string
      attribute :prenom, :string
      attribute :datenaissance, :date
      attribute :codeinseepaysnai, :string
      attribute :codeinseecommune, :string

      validates_presence_of %i[
        titre
        nomusage
        nomnaissance
        prenom
        datenaissance
        codeinseepaysnai
      ]

      validates_presence_of :codeinseecommune, if: :born_in_france?

      def fragment(xml)
        xml.titre(titre)
        xml.prenom(prenom)
        xml.nomusage(nomusage)
        xml.nomnaissance(nomnaissance)
        xml.datenaissance(I18n.l(datenaissance, format: :asp))
        xml.codeinseepaysnai(codeinseepaysnai)
        xml.codeinseecommune(codeinseecommune)
      end

      private

      def born_in_france?
        codeinseepaysnai == Adresse::FRANCE_INSEE_COUNTRY_CODE
      end
    end
  end
end
