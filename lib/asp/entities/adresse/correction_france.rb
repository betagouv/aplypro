# frozen_string_literal: true

module ASP
  module Entities
    module Adresse
      class CorrectionFrance < France
        attribute :numerovoie, :string
        attribute :libellevoie, :string
        attribute :codeextensionvoie, :string
        attribute :codetypevoie, :string
        attribute :cpltdistribution, :string

        validates_presence_of %i[
          libellevoie
        ]

        validates_length_of :libellevoie, maximum: InduFrance::LIBELLEVOIE_MAX_LENGTH
        validates_length_of :cpltdistribution, maximum: InduFrance::ADRESSE_ATTR_MAX_LENGTH, allow_nil: true
        CODETYPEVOIE_MAX_LENGTH = 4

        validates_length_of :codeextensionvoie, maximum: 1, allow_nil: true
        validates_length_of :codetypevoie, maximum: CODETYPEVOIE_MAX_LENGTH, allow_nil: true

        def self.payment_mapper_class
          Mappers::Adresse::CorrectionFranceMapper
        end

        def fragment(xml)
          xml.codetypeadr(codetypeadr)
          voie_fragment(xml)
          xml.codecominsee(codecominsee)
          xml.codeinseepays(codeinseepays)
          xml.codepostalcedex(codepostalcedex)
        end

        private

        def voie_fragment(xml)
          xml.numerovoie(numerovoie) if numerovoie.present?
          xml.libellevoie(libellevoie)
          xml.codeextensionvoie(codeextensionvoie) if codeextensionvoie.present?
          xml.codetypevoie(codetypevoie) if codetypevoie.present?
          xml.cpltdistribution(cpltdistribution) if cpltdistribution.present?
        end
      end
    end
  end
end
