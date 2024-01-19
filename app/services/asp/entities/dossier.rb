# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Dossier < Entity
      include ASP::Constants

      attribute :numadm, :string

      validates :numadm, presence: true

      def fragment(builder)
        builder.dossier do |xml|
          xml.numadm(numadm)
          xml.listeprestadoss do
            PrestationDossier.from_payment(payment).to_xml(xml)
          end
        end
      end
    end
  end
end
