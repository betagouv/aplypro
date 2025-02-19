# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class InduFrance < Entity
        ADRESSE_ATTR_MAX_LENGTH = 38

        attribute :pointremise, :string
        attribute :cpltdistribution, :string
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

        validates_length_of :pointremise, maximum: ADRESSE_ATTR_MAX_LENGTH
        validates_length_of :cpltdistribution, maximum: ADRESSE_ATTR_MAX_LENGTH, allow_nil: true

        def self.payment_mapper_class
          Mappers::Adresse::InduFranceMapper
        end

        def root_node_name
          "adresse"
        end

        def fragment(xml)
          xml.pointremise(pointremise)
          xml.cpltdistribution(cpltdistribution) if cpltdistribution.present?
          xml.codetypeadr(codetypeadr)
          xml.codeinseepays(codeinseepays)
          xml.codepostalcedex(codepostalcedex)
          xml.codecominsee(codecominsee)
        end
      end
    end
  end
end
