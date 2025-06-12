# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class InduEtranger < Entity
        ADRESSE_ATTR_MAX_LENGTH = 38

        attribute :localiteetranger, :string
        attribute :bureaudistribetranger, :string
        attribute :voiepointgeoetranger, :string
        attribute :districtetranger, :string
        attribute :regionetranger, :string
        attribute :codetypeadr, :string
        attribute :codeinseepays, :string

        validates_presence_of %i[
          localiteetranger
          bureaudistribetranger
          codetypeadr
          codeinseepays
        ]

        validates_length_of :localiteetranger, maximum: ADRESSE_ATTR_MAX_LENGTH
        validates_length_of :bureaudistribetranger, maximum: ADRESSE_ATTR_MAX_LENGTH

        validates_length_of :voiepointgeoetranger, maximum: ADRESSE_ATTR_MAX_LENGTH, allow_nil: true
        validates_length_of :districtetranger, maximum: ADRESSE_ATTR_MAX_LENGTH, allow_nil: true
        validates_length_of :regionetranger, maximum: ADRESSE_ATTR_MAX_LENGTH, allow_nil: true

        def self.mapper_class
          Mappers::Adresse::InduEtrangerMapper
        end

        def root_node_name
          "adresse"
        end

        def fragment(xml) # rubocop:disable Metrics/AbcSize
          xml.codetypeadr(codetypeadr)
          xml.codeinseepays(codeinseepays)

          xml.localiteetranger(localiteetranger)
          xml.bureaudistribetranger(bureaudistribetranger)

          xml.voiepointgeoetranger(voiepointgeoetranger) if voiepointgeoetranger.present?
          xml.districtetranger(districtetranger) if districtetranger.present?
          xml.regionetranger(regionetranger) if regionetranger.present?
        end
      end
    end
  end
end
