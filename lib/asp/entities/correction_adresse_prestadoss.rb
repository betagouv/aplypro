# frozen_string_literal: true

module ASP
  module Entities
    class CorrectionAdressePrestadoss < Prestadoss
      def self.payment_mapper_class
        ASP::Mappers::PrestadossMapper
      end

      def root_node_name
        "prestadoss"
      end

      def fragment(xml)
        prestadoss_xml(xml)
        xml.adressesprestadoss { adresse_entity_class.from_payment_request(payment_request).to_xml(xml) }
        xml.coordpaiesprestadoss { CoordPaie.from_payment_request(payment_request).to_xml(xml) }
      end

      private

      def adresse_entity_class
        payment_request.student.lives_in_france? ? Adresse::CorrectionFrance : Adresse::CorrectionEtranger
      end
    end
  end
end
