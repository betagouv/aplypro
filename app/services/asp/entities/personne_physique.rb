# frozen_string_literal: true

module ASP
  module Entities
    class PersonnePhysique < Entity
      extend StudentMapper

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

      def self.student_mapper_class
        ASP::Mappers::StudentMapper
      end

      def fragment(builder)
        builder.persphysique do |xml|
          xml.titre(titre)
          xml.prenom(prenom)
          xml.nomusage(nomusage)
          xml.nomnaissance(nomnaissance)
          xml.datenaissance(I18n.l(datenaissance, format: :asp))
          xml.codeinseepaysnai(codeinseepaysnai)
          xml.codeinseecommune(codeinseecommune)
        end
      end

      private

      def born_in_france?
        codeinseepaysnai == Adresse::FRANCE_INSEE_COUNTRY_CODE
      end
    end
  end
end
