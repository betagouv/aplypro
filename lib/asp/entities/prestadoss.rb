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

      known_with :id_prestation_dossier

      validates_presence_of %i[numadm datecomplete datereceptionprestadoss montanttotalengage valeur]

      validates_length_of :numadm, within: 20..21

      def xml_root_args
        if known_record?
          { idPrestaDoss: id_prestation_dossier, **ASP_MODIFICATION }
        else
          {}
        end
      end

      def fragment(xml)
        prestadoss_xml(xml)

        xml.adressesprestadoss { Adresse.from_payment_request(payment_request).to_xml(xml) }
        xml.coordpaiesprestadoss { CoordPaie.from_payment_request(payment_request).to_xml(xml) }
        xml.listeelementpaiement { ElementPaiement.from_payment_request(payment_request).to_xml(xml) }
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
