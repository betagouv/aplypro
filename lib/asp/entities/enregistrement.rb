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
        xml.natureindividu("P")
        PersPhysique.from_payment_request(payment_requests.first).to_xml(xml)
        xml.adressesindividu { adresse_entity_class.from_payment_request(payment_requests.first).to_xml(xml) }

        xml.listedossier { Dossier.from_payment_requests(payment_requests).to_xml(xml) }

        # TODO
        # rescue ActiveModel::ValidationError => e
        #   Sentry.capture_exception(
        #     ASP::Errors::PaymentFileValidationError.new(
        #       "Payment file validation failed for p_r: #{payment_request.id} " \
        #       "with message #{e.message}"
        #     )
        #   )
        #   raise e
      end

      def individu_attrs
        if known_record?
          { idIndividu: id_individu, **ASP_MODIFICATION }
        else
          {}
        end
      end
    end
  end
end
