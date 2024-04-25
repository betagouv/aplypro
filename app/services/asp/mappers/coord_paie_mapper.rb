# frozen_string_literal: true

module ASP
  module Mappers
    class CoordPaieMapper
      PRINCIPAL_ADDRESS_TYPE = "PRINCIPALE"
      ASSIMILATED_FRENCH_COUNTRY_CODES = %w[FR GF GP MC MQ NC PF PM RE WF YT].freeze

      ALLOWED_CHARACTERS = %w[/ - ? : ( ) . , '].freeze
      RIB_NAME_MASK = /\A[\s[[:alnum:]]#{ALLOWED_CHARACTERS.join}]+\z/

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

      def codeisopays
        iban.country_code
      end

      def zonebban
        iban.bban.to_s
      end

      def clecontrole
        iban.check_digits
      end

      def intitdest
        rib.name
           .delete("&")
           .squish
           .gsub("_", "")
           .gsub(";", " ")
           .tap do |value|
          if !RIB_NAME_MASK.match?(value)
            raise ArgumentError, "the RIB ##{rib.id} name is still invalid after sanitisation"
          end
        end
      end

      # @emaildoc
      #   Pour un IBAN France ou assimilé (code ISO pays = FR, GF, GP, MC,
      #   MQ, NC, PF, PM, RE, WF, YT), il faut supprimer les "XXX" en fin
      #   de BIC si existants.
      #
      #   => Pour être complet, il faut ajouter "XXX" si [l'IBAN ne
      #   commence pas par le code pays "FR", "GF", "GP", "MC", "MQ",
      #   "NC", "PF", "PM", "RE", "WF" ou "YT"} ET [le BIC comporte 8
      #   caractères]
      def bic
        bic = rib.bic

        if french_rib?
          bic.delete_suffix("XXX")
        elsif bic.length == 8
          bic.ljust(11, "X")
        else
          bic
        end
      end

      private

      def french_rib?
        ASSIMILATED_FRENCH_COUNTRY_CODES.include?(iban.country_code)
      end
    end
  end
end
