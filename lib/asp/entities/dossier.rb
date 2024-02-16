# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Dossier < Entity
      include ASP::Constants

      attribute :numadm, :string
      attribute :id_dossier, :string
      attribute :codedispositif, :string

      validates_presence_of %i[numadm codedispositif]

      def xml_root_args
        { idDoss: id_dossier, **ASP_NO_MODIFICATION } if id_dossier.present?
      end

      def fragment(xml)
        xml.numadm(numadm)
        xml.codedispositif(codedispositif)
        xml.listeprestadoss do
          Prestadoss.from_payment_request(payment).to_xml(xml)
        end
      end
    end
  end
end
