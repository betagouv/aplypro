# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class PfmpsPayable < Stats::Count
        def initialize(start_year) # rubocop:disable Metrics/AbcSize
          payable_base = Pfmp.for_year(start_year).in_state(:validated).finished.distinct
                             .joins(schooling: { student: :ribs })
                             .merge(Schooling.with_attributive_decisions)
                             .merge(Student.asp_ready)
                             .where(schoolings: { status: 0 })
                             .where("pfmps.start_date >= schoolings.start_date")
                             .where("pfmps.end_date <= schoolings.end_date")

          paid_pfmp_ids = payable_base
                          .joins(payment_requests: :asp_payment_request_transitions)
                          .where(asp_payment_request_transitions: { most_recent: true, to_state: "paid" })
                          .distinct
                          .pluck(:id)

          super(
            all: payable_base.where.not(id: paid_pfmp_ids)
          )
        end

        def key
          :pfmps_payable_count
        end

        def title
          "Nb. PFMPs payables"
        end

        def tooltip_key
          "stats.count.pfmps_payable"
        end

        def with_mef_and_establishment
          Pfmp.joins(schooling: { classe: %i[mef establishment] })
        end

        def with_establishment
          Pfmp.joins(schooling: { classe: :establishment })
        end
      end
    end
  end
end
