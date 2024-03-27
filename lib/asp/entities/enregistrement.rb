# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Enregistrement < Entity
      include ASP::Constants

      attribute :id_enregistrement, :string
      attribute :id_individu, :string

      validates_presence_of :id_enregistrement

      known_with :id_individu

      def xml_root_args
        { idEnregistrement: id_enregistrement }
      end

      def fragment(xml)
        xml.individu(**individu_attrs) { individu(xml) }
      end

      def individu(xml)
        if new_record?
          xml.natureindividu("P")
          PersPhysique.from_payment_request(payment_request).to_xml(xml)
          xml.adressesindividu { Adresse.from_payment_request(payment_request).to_xml(xml) }
          xml.coordpaiesindividu { CoordPaie.from_payment_request(payment_request).to_xml(xml) }
        end

        xml.listedossier { Dossier.from_payment_request(payment_request).to_xml(xml) }
      end

      def individu_attrs
        if known_record?
          { idIndividu: id_individu, **ASP_NO_MODIFICATION }
        else
          {}
        end
      end
    end
  end
end
