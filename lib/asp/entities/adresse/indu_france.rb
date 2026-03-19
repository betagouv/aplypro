# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class InduFrance < Entity
        LIBELLEVOIE_MAX_LENGTH = 28
        ADRESSE_ATTR_MAX_LENGTH = 38

        attribute :libellevoie, :string
        attribute :cpltdistribution, :string
        attribute :codetypeadr, :string
        attribute :codecominsee, :string
        attribute :codeinseepays, :string
        attribute :codepostalcedex, :string

        validates_presence_of %i[
          libellevoie
          codetypeadr
          codeinseepays
          codepostalcedex
          codecominsee
        ]

        validates_length_of :libellevoie, maximum: LIBELLEVOIE_MAX_LENGTH
        validates_length_of :cpltdistribution, maximum: ADRESSE_ATTR_MAX_LENGTH, allow_nil: true

        def self.payment_mapper_class
          Mappers::Adresse::InduFranceMapper
        end

        def root_node_name
          "adresse"
        end

        def fragment(xml)
          xml.libellevoie(libellevoie)
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
