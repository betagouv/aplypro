# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class InduEtranger < Entity
        ADRESSE_ATTR_MAX_LENGTH = 38

        attribute :localiteetranger, :string, limit: ADRESSE_ATTR_MAX_LENGTH
        attribute :bureaudistribetranger, :string, limit: ADRESSE_ATTR_MAX_LENGTH
        attribute :voiepointgeoetranger, :string, limit: ADRESSE_ATTR_MAX_LENGTH
        attribute :districtetranger, :string, limit: ADRESSE_ATTR_MAX_LENGTH
        attribute :regionetranger, :string, limit: ADRESSE_ATTR_MAX_LENGTH
        attribute :codetypeadr, :string
        attribute :codeinseepays, :string

        validates_presence_of %i[
          localiteetranger
          bureaudistribetranger
          codetypeadr
          codeinseepays
        ]

        def self.payment_mapper_class
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
