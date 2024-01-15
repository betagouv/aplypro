# frozen_string_literal: true

module ASP
  module Entities
    class Adresse < Entity
      extend StudentMapper

      FRANCE_INSEE_COUNTRY_CODE = "99100"

      attribute :codetypeadr, :string
      attribute :codecominsee, :string
      attribute :codeinseepays, :string
      attribute :codepostalcedex, :string
      attribute :localiteetranger, :string
      attribute :bureaudistribetranger, :string

      validates_presence_of %i[
        codetypeadr
        codeinseepays
      ]

      validates :codepostalcedex, :codecominsee, presence: true, if: :french_address?
      validates :bureaudistribetranger, :localiteetranger, presence: true, if: :foreign_address?

      def self.student_mapper_class
        ASP::Mappers::AddressMapper
      end

      def fragment(builder)
        builder.adresse do |xml|
          xml.codetypeadr(codetypeadr)
          xml.codeinseepays(codeinseepays)

          if french_address?
            xml.codepostalcedex(codepostalcedex)
            xml.codecominsee(codecominsee)
          else
            xml.localiteetranger(localiteetranger)
            xml.bureaudistribetranger(bureaudistribetranger)
          end
        end
      end

      private

      def french_address?
        codeinseepays == FRANCE_INSEE_COUNTRY_CODE
      end

      def foreign_address?
        !french_address?
      end
    end
  end
end
