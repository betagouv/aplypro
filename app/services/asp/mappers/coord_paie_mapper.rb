# frozen_string_literal: true

module ASP
  module Mappers
    class CoordPaieMapper
      PRINCIPAL_ADDRESS_TYPE = "PRINCIPALE"

      MAPPING = {
        bic: :bic
      }.freeze

      attr_reader :rib, :iban

      def initialize(payment_request)
        @rib = payment_request.student.rib
        @iban = Bank::IBAN.new(rib.iban)
      end

      MAPPING.each do |name, attr|
        define_method(name) { rib[attr] }
      end

      # @emaildoc
      #   Le troncage à 32 caractères est la solution la plus simple à
      #   mettre en œuvre pour tout le monde, c'est ce que nous
      #   préconisons. Le risque de rendre la donnée inutilisable est
      #   minime (pas de traitement/contrôle automatisé sur ce champ à
      #   l'ASP).
      def intitdest
        rib.name.first(32)
      end

      def codeisopays
        iban.country_code
      end

      def zonebban
        iban.bban.to_s
      end

      def clecontrole
        iban.check_digits
      end

      # @emaildoc
      #   Pour un IBAN France ou assimilé (code ISO pays = FR, GF, GP, MC,
      #   MQ, NC, PF, PM, RE, WF, YT), il faut supprimer les "XXX" en fin
      #   de BIC si existants.
      def bic
        if rib.bic.ends_with?("XXX")
          rib.bic[..-4]
        else
          rib.bic
        end
      end
    end
  end
end
