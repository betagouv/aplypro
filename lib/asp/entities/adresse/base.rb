# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class Base < Entity
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

        def fragment(xml)
          xml.codetypeadr(codetypeadr)
          xml.codeinseepays(codeinseepays)
          xml.codepostalcedex(codepostalcedex)
          xml.codecominsee(codecominsee)
        end

        def self.payment_mapper_class
          ASP::Mappers::Adresse::BaseMapper
        end

        def root_node_name
          "adresse"
        end
      end
    end
  end
end
