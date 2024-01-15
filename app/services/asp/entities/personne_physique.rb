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
        codeinseecommune
      ]

      def self.student_mapper_class
        ASP::Mappers::StudentMapper
      end

      def to_xml(builder = Nokogiri::XML::Builder.new)
        validate!

        builder.persphysique do |xml|
          xml.titre(titre)
          xml.prenom(prenom)
          xml.nomusage(nomusage)
          xml.nomnaissance(nomnaissance)
          xml.datenaissance(I18n.l(datenaissance, format: :asp))
          xml.codeinseepaysnai(codeinseepaysnai)
        end

        builder.to_xml
      end
    end
  end
end
