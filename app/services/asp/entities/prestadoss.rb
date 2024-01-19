# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Prestadoss < Entity
      include ASP::Constants

      attribute :numadm, :string
      attribute :datecomplete, :asp_date
      attribute :datereceptionprestadoss, :asp_date
      attribute :montanttotalengage, :string
      attribute :valeur, :string

      validates_presence_of %i[numadm datecomplete datereceptionprestadoss montanttotalengage valeur]

      def fragment(xml)
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
