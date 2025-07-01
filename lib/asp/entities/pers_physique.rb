# frozen_string_literal: true

module ASP
  module Entities
    class PersPhysique < Entity
      FIRST_NAME_MAX_LENGTH = 20
      LAST_NAME_MAX_LENGTH  = 50

      attribute :titre, :string
      attribute :nomusage, :string, limit: LAST_NAME_MAX_LENGTH
      attribute :nomnaissance, :string, limit: LAST_NAME_MAX_LENGTH
      attribute :prenom, :string, limit: FIRST_NAME_MAX_LENGTH
      attribute :autresprenoms, :string, limit: 40
      attribute :datenaissance, :asp_date
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

      def fragment(xml) # rubocop:disable Metrics/AbcSize
        xml.titre(titre)
        xml.prenom(prenom)
        xml.autresprenoms(autresprenoms) if autresprenoms.present?
        xml.nomusage(nomusage)
        xml.nomnaissance(nomnaissance)
        xml.datenaissance(datenaissance)
        xml.codeinseepaysnai(codeinseepaysnai)
        xml.codeinseecommune(codeinseecommune) if born_in_france?
      end

      private

      def born_in_france?
        InseeCodes.in_france?(codeinseepaysnai)
      end
    end
  end
end
