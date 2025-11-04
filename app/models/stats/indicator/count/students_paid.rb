# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class StudentsPaid < Stats::Count
        def initialize(start_year)
          super(
            all: Student.for_year(start_year)
                        .joins(:schoolings)
                        .joins(pfmps: { payment_requests: :asp_payment_request_transitions })
                        .where("asp_payment_request_transitions.to_state": :paid)
          )
        end

        def key
          :students_paid_count
        end

        def title
          "Nb. élèves payés"
        end

        def tooltip_key
          "stats.count.students_paid"
        end

        def with_mef_and_establishment
          Student.joins(schoolings: { classe: %i[mef establishment] })
        end

        def with_establishment
          Student.joins(schoolings: { classe: :establishment })
        end
      end
    end
  end
end
