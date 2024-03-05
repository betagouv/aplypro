# frozen_string_literal: true

module ASP
  module Mappers
    class PrestadossMapper
      attr_reader :schooling, :pfmp

      def initialize(payment_request)
        @pfmp = payment_request.pfmp
        @schooling = pfmp.schooling
      end

      def numadm
        index = pfmp.relative_human_index.to_s.rjust(2, "0")

        schooling.attributive_decision_number + index
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

      def id_prestation_dossier
        pfmp.asp_prestation_dossier_id
      end
    end
  end
end
