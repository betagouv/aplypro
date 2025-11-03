# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class PfmpsPaidPayable < Stats::Ratio
        def initialize(start_year) # rubocop:disable Metrics/AbcSize
          paid_pfmps = Pfmp.for_year(start_year)
                           .joins(:payment_requests)
                           .merge(ASP::PaymentRequest.in_state(:paid))
                           .distinct

          payable_pfmps = Pfmp.for_year(start_year).in_state(:validated).finished.distinct
                              .joins(schooling: { student: :ribs })
                              .merge(Schooling.with_attributive_decisions)
                              .merge(Student.asp_ready)
                              .where(schoolings: { status: 0 })
                              .where("pfmps.start_date >= schoolings.start_date")
                              .where("pfmps.end_date <= schoolings.end_date")

          super(
            subset: paid_pfmps,
            all: payable_pfmps
          )
        end

        def title
          "Part PFMPs payées/payables"
        end

        def tooltip_key
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
