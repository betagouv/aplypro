# frozen_string_literal: true

module ASP
  module Mappers
    class CoordPaieMapper
      PRINCIPAL_ADDRESS_TYPE = "PRINCIPALE"
      ASSIMILATED_FRENCH_COUNTRY_CODES = %w[FR GF GP MC MQ NC PF PM RE WF YT].freeze

      PARTICULAR_BICS = {
        CREDIT_MUTUEL_ARKEA: "CMBRFR2BARK",
        BNP_PARIBAS_METZ: "BNPAFRPPMTZ",
        BNP_PARIBAS_LYON: "BNPAFRPPTAS"
      }.freeze

      MAPPING = {
        bic: :bic
      }.freeze

      attr_reader :rib, :iban

      def initialize(payment_request)
        @rib = payment_request.rib_with_fallback
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
        ASP::RibNameSanitiser.call(rib.name)
      end

      # @emaildoc
      #   Pour un IBAN France ou assimilé (code ISO pays = FR, GF, GP, MC,
      #   MQ, NC, PF, PM, RE, WF, YT), il faut supprimer les "XXX" en fin
      #   de BIC si existants.
      #
      #   Pour un IBAN incomplet (BIC sur 8 caractères), il faut ajouter
      #   "XXX" si [l'IBAN ne commence pas par le code pays "FR", "GF",
      #   "GP", "MC", "MQ", "NC", "PF", "PM", "RE", "WF" ou "YT"} ET [le
      #   BIC comporte 8 caractères]
      #
      #   Pour un IBAN avec un BIC non accepté par l'ASP ("CMBRFR2BARK")
      #   il faut appliquer les transformations suivantes : {CMBRFR2BARK
      #   => CMBRFR2B}
      def bic
        bic = rib.bic

        if particular_bic?
          particular_rib_treatment(bic)
        elsif french_rib?
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

      def particular_bic?
        PARTICULAR_BICS.values.include?(rib.bic)
      end

      def particular_rib_treatment(bic)
        case PARTICULAR_BICS.key(bic)
        when :CREDIT_MUTUEL_ARKEA
          bic.gsub("ARK", "")
        when :BNP_PARIBAS_METZ
          bic.gsub("MTZ", "")
        when :BNP_PARIBAS_LYON
          bic.gsub("TAS", "")
        end
      end
    end
  end
end
