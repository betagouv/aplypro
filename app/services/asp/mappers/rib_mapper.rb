# frozen_string_literal: true

module ASP
  module Mappers
    class RibMapper
      PRINCIPAL_ADDRESS_TYPE = "PRINCIPALE"

      MAPPING = {
        intitdest: :name,
        bic: :bic
      }.freeze

      attr_reader :rib, :iban

      def initialize(student)
        @rib = student.rib
        @iban = Bank::IBAN.new(rib)
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
