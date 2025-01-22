# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class Indu < Entity
        ADRESSE_ATTR_MAX_LENGTH = 38

        attribute :pointremise, :string, limit: ADRESSE_ATTR_MAX_LENGTH
        attribute :cpltdistribution, :string, limit: ADRESSE_ATTR_MAX_LENGTH
        attribute :codetypeadr, :string
        attribute :codecominsee, :string
        attribute :codeinseepays, :string
        attribute :codepostalcedex, :string

        validates_presence_of %i[
          pointremise
          codetypeadr
          codeinseepays
          codepostalcedex
          codecominsee
        ]

        def self.payment_mapper_class
          Mappers::Adresse::InduMapper
        end

        def root_node_name
          "adresse"
        end

        def fragment(xml)
          xml.pointremise(pointremise)
          xml.cpltdistribution(cpltdistribution)
          xml.codetypeadr(codetypeadr)
          xml.codeinseepays(codeinseepays)
          xml.codepostalcedex(codepostalcedex)
          xml.codecominsee(codecominsee)
        end
      end
    end
  end
end
