# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsPayable < Stats::Count
        def initialize(start_year)
          payable_base = Pfmp.for_year(start_year).finished.distinct
                             .in_state(:validated, :rectified)
                             .joins(:schooling)
                             .merge(Schooling.with_attributive_decisions)
                             .where(schoolings: { status: 0 })

          paid_pfmp_ids = payable_base
                          .joins(payment_requests: :asp_payment_request_transitions)
                          .where(asp_payment_request_transitions: { most_recent: true, to_state: "paid" })
                          .distinct
                          .pluck(:id)

          super(
            all: payable_base.where.not(id: paid_pfmp_ids)
          )
        end

        def self.key
          :pfmps_payable_count
        end

        def self.title
          "Nb. PFMPs payables"
        end

        def self.tooltip_key
          "stats.count.pfmps_payable"
        end

        def with_mef_and_establishment
          Pfmp.joins(schooling: { classe: %i[mef establishment school_year] })
        end

        def with_establishment
          Pfmp.joins(schooling: { classe: %i[establishment school_year] })
        end
      end
    end
  end
end
