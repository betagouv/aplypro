# frozen_string_literal: true

module ASP
  module Entities
    class CorrectionAdresseEnregistrement < Enregistrement
      def self.payment_mapper_class
        ASP::Mappers::EnregistrementMapper
      end

      def root_node_name
        "enregistrement"
      end

      def individu(xml)
        xml.natureindividu("P")
        PersPhysique.from_payment_request(payment_request).to_xml(xml)
        xml.adressesindividu { adresse_entity_class.from_payment_request(payment_request).to_xml(xml) }
        xml.listedossier { CorrectionAdresseDossier.from_payment_request(payment_request).to_xml(xml) }
      rescue ActiveModel::ValidationError => e
        Sentry.capture_exception(
          ASP::Errors::PaymentFileValidationError.new(
            "Correction adresse file validation failed for p_r: #{payment_request.id} with message #{e.message}"
          )
        )
        raise e
      end
    end
  end
end
