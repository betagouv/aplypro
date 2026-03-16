# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class France < Entity
        attribute :codetypeadr, :string
        attribute :codecominsee, :string
        attribute :codeinseepays, :string
        attribute :codepostalcedex, :string

        validates_presence_of %i[
          codetypeadr
          codeinseepays
          codepostalcedex
          codecominsee
        ]

        def self.payment_mapper_class
          Mappers::Adresse::FranceMapper
        end

        def root_node_name
          "adresse"
        end

        def fragment(xml)
          xml.codetypeadr(codetypeadr)
          xml.codecominsee(codecominsee)
          xml.codeinseepays(codeinseepays)
          xml.codepostalcedex(codepostalcedex)
        end
      end
    end
  end
end
