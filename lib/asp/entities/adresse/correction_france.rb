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

        validates_presence_of :libellevoie

        def self.payment_mapper_class
          Mappers::Adresse::CorrectionFranceMapper
        end

        def fragment(xml)
          xml.numerovoie(numerovoie) if numerovoie.present?
          xml.libellevoie(libellevoie)
          xml.codeextensionvoie(codeextensionvoie) if codeextensionvoie.present?
          xml.codetypevoie(codetypevoie) if codetypevoie.present?
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
