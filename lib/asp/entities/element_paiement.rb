# frozen_string_literal: true

module ASP
  module Entities
    class ElementPaiement < Entity
      attribute :objetecheance, :string
      attribute :codetypeversement, :string
      attribute :mttotalfinancement, :string
      attribute :usprinc, :string

      validates_presence_of %i[objetecheance codetypeversement mttotalfinancement usprinc]

      def fragment(xml)
        xml.objetecheance(objetecheance)
        xml.listeversement do
          xml.versement do
            xml.codetypeversement(codetypeversement)
            xml.listefinancement do
              xml.financement do
                xml.mttotalfinancement(mttotalfinancement)
                xml.usprinc(usprinc)
              end
            end
          end
        end
      end
    end
  end
end
