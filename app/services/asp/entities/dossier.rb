# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Dossier < Entity
      extend StudentMapper

      include ASP::Constants

      attribute :numadm, :string
      attribute :datecomplete, :asp_date
      attribute :datereceptionprestadoss, :asp_date
      attribute :montanttotalengage, :string
      attribute :valeur, :string

      validates_presence_of %i[numadm datecomplete datereceptionprestadoss montanttotalengage valeur]

      def self.student_mapper_class
        ASP::Mappers::DossierMapper
      end

      def fragment(builder)
        builder.dossier do |xml|
          xml.numadm(numadm)
          xml.codedispositif(CODE_DISPOSITIF)
          xml.listeprestadoss do
            listeprestadoss(xml)
          end
        end
      end

      private

      def listeprestadoss(builder)
        builder.prestadoss do |xml|
          xml.numadm(numadm)
          xml.codeprestadispo(CODE_DISPOSITIF)
          xml.datecompletude(datecomplete)
          xml.datereceptionprestadoss(datereceptionprestadoss)
          xml.montanttotalengage(montanttotalengage)
          xml.code("D")
          xml.valeur(valeur)
          xml.indicrattachusprestadispo("O")
        end
      end
    end
  end
end
