# frozen_string_literal: true

module ASP
  module Entities
    class PersonnePhysique
      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::AttributeAssignment

      attribute :titre, :string
      attribute :sexe, :string
      attribute :nomusage, :string
      attribute :nomnaissance, :string
      attribute :prenom, :string
      attribute :datenaissance, :string
      attribute :codeinseepaysnai, :string
      attribute :codeinseecommune, :string

      validates_presence_of %i[
        titre
        sexe
        nomusage
        nomnaissance
        prenom
        datenaissance
        codeinseepaysnai
        codeinseecommune
      ]

      def self.from_student(student)
        mapper = ASP::Mappers::StudentMapper.new(student)

        new.tap do |instance|
          mapped_attributes = attribute_names.index_with { |attr| mapper.send(attr) }

          instance.assign_attributes(mapped_attributes)
        end
      end

      def to_xml(builder = Nokogiri::XML::Builder.new)
        validate!

        builder.personnephysique do |xml|
          xml.titre(titre)
          xml.prenom(prenom)
          xml.nomusage(nomusage)
        end

        builder.to_xml
      end
    end
  end
end
