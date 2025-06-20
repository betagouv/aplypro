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

        def self.mapper_class
          Mappers::Adresse::FranceMapper
        end

        def root_node_name
          "adresse"
        end

        def fragment(xml)
          xml.codetypeadr(codetypeadr)
          xml.codeinseepays(codeinseepays)
          xml.codepostalcedex(codepostalcedex)
          xml.codecominsee(codecominsee)
        end
      end
    end
  end
end
