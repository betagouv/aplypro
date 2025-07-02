# frozen_string_literal: true

require "asp/constants"

module ASP
  module Entities
    class Dossier < Entity
      include ASP::Constants

      attribute :numadm, :string
      attribute :id_dossier, :string
      attribute :codedispositif, :string

      known_with :id_dossier

      validates_presence_of %i[numadm codedispositif]
      validates_length_of :numadm, within: 18..19, too_short: :numadm_length_error, too_long: :numadm_length_error

      def xml_root_args
        if known_record?
          { idDoss: id_dossier, **ASP_NO_MODIFICATION }
        else
          {}
        end
      end

      def fragment(xml)
        xml.numadm(numadm)
        xml.codedispositif(codedispositif)

        xml.listeprestadoss do
          Prestadoss.from_payment_request(payment_request).to_xml(xml)
        end
      end

      private

      def numadm_length_error
        I18n.t("errors.messages.numadm_length_error", value: numadm)
      end
    end
  end
end
