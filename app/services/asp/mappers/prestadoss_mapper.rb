# frozen_string_literal: true

module ASP
  module Mappers
    class PrestadossMapper
      attr_reader :schooling, :pfmp

      def initialize(payment_request)
        @pfmp = payment_request.pfmp
        @schooling = payment_request.schooling
      end

      def numadm
        pfmp.administrative_number
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
        schooling.establishment.department_code
      end

      def id_prestation_dossier
        pfmp.asp_prestation_dossier_id
      end
    end
  end
end
