# frozen_string_literal: true

module ASP
  module Entities
    class CorrectionAdresseDossier < Dossier
      def self.payment_mapper_class
        ASP::Mappers::DossierMapper
      end

      def root_node_name
        "dossier"
      end

      def xml_root_args
        known_record? ? { idDoss: id_dossier, **ASP_MODIFICATION } : {}
      end

      def fragment(xml)
        xml.numadm(numadm)
        xml.codedispositif(codedispositif)
        xml.listeprestadoss { CorrectionAdressePrestadoss.from_payment_request(payment_request).to_xml(xml) }
      end
    end
  end
end
