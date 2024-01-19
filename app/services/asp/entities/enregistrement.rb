# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Enregistrement < Entity
      include ASP::Constants

      attribute :id_enregistrement, :string

      validates_presence_of :id_enregistrement

      def fragment(builder)
        builder.enregistrement(idEnregistrement: id_enregistrement) do |xml|
          individu(xml)
        end
      end

      def individu(xml)
        xml.individu do
          xml.natureindividu("P")
          PersonnePhysique.from_payment(payment).to_xml(xml)
          xml.adressesindividu { Adresse.from_payment(payment).to_xml(xml) }
          xml.coordpaiesindividu { CoordonneesPaiement.from_payment(payment).to_xml(xml) }
          xml.listedossier { Dossier.from_payment(payment).to_xml(xml) }
        end
      end
    end
  end
end
