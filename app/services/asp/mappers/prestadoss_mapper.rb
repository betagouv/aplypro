# frozen_string_literal: true

module ASP
  module Mappers
    class PrestadossMapper
      MAPPING = {
        numadm: :attributive_decision_number
      }.freeze

      attr_reader :schooling

      def initialize(payment)
        @schooling = payment.schooling
      end

      MAPPING.each do |name, attr|
        define_method(name) { schooling.send(attr) }
      end

      def datecomplete
        Time.zone.today
      end

      def datereceptionprestadoss
        Time.zone.today
      end

      def montanttotalengage
        schooling.mef.wage.yearly_cap
      end

      def valeur
        schooling.establishment.region_code.rjust(3, "0")
      end
    end
  end
end
