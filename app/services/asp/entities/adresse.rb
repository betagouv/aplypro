# frozen_string_literal: true

module ASP
  module Entities
    class Adresse
      FRANCE_INSEE_COUNTRY_CODE = "99100"

      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::AttributeAssignment

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

      def self.from_student(student)
        mapper = ASP::Mappers::AddressMapper.new(student)

        new.tap do |instance|
          mapped_attributes = attribute_names.index_with { |attr| mapper.send(attr) if mapper.respond_to?(attr) }

          instance.assign_attributes(mapped_attributes)
        end
      end

      def to_xml(builder = Nokogiri::XML::Builder.new)
        validate!

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

        builder.to_xml
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
