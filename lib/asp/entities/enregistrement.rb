# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Enregistrement < Entity
      include ASP::Constants

      attribute :id_enregistrement, :string

      validates_presence_of :id_enregistrement

      def xml_root_args
        { idEnregistrement: id_enregistrement }
      end

      def fragment(xml)
        xml.individu do
          xml.natureindividu("P")
          PersPhysique.from_payment(payment).to_xml(xml)
          xml.adressesindividu { Adresse.from_payment(payment).to_xml(xml) }
          xml.coordpaiesindividu { CoordPaie.from_payment(payment).to_xml(xml) }
          xml.listedossier { Dossier.from_payment(payment).to_xml(xml) }
        end
      end
    end
  end
end
