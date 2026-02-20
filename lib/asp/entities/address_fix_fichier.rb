# frozen_string_literal: true

module ASP
  module Entities
    class AddressFixFichier < Fichier
      def to_xml
        ASP::Builder.new({ encoding: "UTF-8" }) do |xml|
          xml.fichier(xmlns: XMLNS) do
            parametrage(xml)
            xml.enregistrements do
              payment_requests.each do |payment_request|
                Entities::AddressFixEnregistrement.from_payment_request(payment_request).to_xml(xml)
              end
            end
          end
        end.to_xml
      end
    end
  end
end
