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
    end
  end
end
