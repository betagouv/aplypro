# frozen_string_literal: true

module ASP
  module Entities
    class Fichier
      include ASP::Constants

      include ActiveModel::Validations

      validates_with ASP::SchemaValidator

      attr_reader :payments

      def initialize(payments)
        @payments = payments
      end

      def to_xml
        ASP::Builder.new({ encoding: "UTF-8" }) do |xml|
          xml.fichier(xmlns: XMLNS) do
            parametrage(xml)

            xml.enregistrements do
              @payments.each do |payment|
                Entities::Enregistrement.from_payment_request(payment).to_xml(xml)
              end
            end
          end
        end.to_xml
      end

      def filename
        [
          "nps_ficimport_idp",
          "aplypro_test_dev",
          filename_timestamp
        ].join("_").concat(".xml")
      end

      def parametrage(xml)
        xml.parametrage do
          xml.codesiteope(CODE_SITE_OP)
          xml.codeutilisateur(CODE_UTILISATEUR)
          xml.codedispo(CODE_DISPOSITIF)
          xml.codeprestadispo(CODE_DISPOSITIF)
        end
      end

      private

      def filename_timestamp
        now = DateTime.now
        format = I18n.t("date.formats.asp_filename")

        now.strftime(format)
      end
    end
  end
end
