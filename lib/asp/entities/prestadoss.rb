# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Prestadoss < Entity
      include ASP::Constants

      attribute :numadm, :string
      attribute :id_prestation_dossier, :string
      attribute :datecomplete, :asp_date
      attribute :datereceptionprestadoss, :asp_date
      attribute :montanttotalengage, :string
      attribute :valeur, :string

      validates_presence_of %i[numadm datecomplete datereceptionprestadoss montanttotalengage valeur]

      def xml_root_args
        { idPrestaDoss: id_prestation_dossier, **ASP_NO_MODIFICATION } if id_prestation_dossier.present?
      end

      def fragment(xml)
        prestadoss_xml(xml)

        xml.adressesprestadoss { Adresse.from_payment_request(payment).to_xml(xml) }
        xml.coordpaiesprestadoss { CoordPaie.from_payment_request(payment).to_xml(xml) }
        xml.listeelementpaiement { ElementPaiement.from_payment_request(payment).to_xml(xml) }
      end

      private

      def prestadoss_xml(xml)
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
