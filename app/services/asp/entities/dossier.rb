# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Dossier < Entity
      include ASP::Constants

      attribute :numadm, :string
      attribute :codedispositif, :string

      validates_presence_of %i[numadm codedispositif]

      def fragment(xml)
        xml.numadm(numadm)
        xml.codedispositif(codedispositif)
        xml.listeprestadoss do
          Prestadoss.from_payment(payment).to_xml(xml)
        end
      end
    end
  end
end
