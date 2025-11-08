# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class PfmpsPaidPayable < Stats::Ratio
        def initialize(start_year)
          payable_base = Pfmp.for_year(start_year).in_state(:validated).finished.distinct
                             .joins(schooling: { student: :ribs })
                             .merge(Schooling.with_attributive_decisions)
                             .merge(Student.asp_ready)
                             .where(schoolings: { status: 0 })
                             .where("pfmps.start_date >= schoolings.start_date")
                             .where("pfmps.end_date <= schoolings.end_date")

          paid_pfmps = payable_base
                       .joins(payment_requests: :asp_payment_request_transitions)
                       .where(asp_payment_request_transitions: { most_recent: true, to_state: "paid" })
                       .distinct

          super(
            subset: paid_pfmps,
            all: payable_base
          )
        end

        def self.key
          :pfmps_paid_payable_ratio
        end

        def self.title
          "Part PFMPs payées/payables"
        end

        def self.tooltip_key
          "stats.ratio.pfmps_paid_payable"
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
