# frozen_string_literal: true

module ASP
  module Entities
    class Fichier
      include ASP::Constants

      include ActiveModel::Validations

      validates_with ASP::SchemaValidator

      attr_reader :schoolings_payment_requests, :schoolings

      def initialize(payment_requests)
        @schoolings_payment_requests = payment_requests.group_by(&:schooling)
        @schoolings = @schoolings_payment_requests.keys
      end

      def to_xml
        ASP::Builder.new({ encoding: "UTF-8" }) do |xml|
          xml.fichier(xmlns: XMLNS) do
            parametrage(xml)

            xml.enregistrements do
              schoolings.each do |schooling|
                Entities::Enregistrement.from_schooling(schooling).to_xml(xml)
              end
            end
          end
        end.to_xml
      end

      def filename
        @filename ||= [
          "nps_ficimport_idp",
          ENV.fetch("APLYPRO_ASP_FILENAME"),
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
