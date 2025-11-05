# frozen_string_literal: true

module Stats
  module Indicator
    module Ratio
      class StudentsPaid < Stats::Ratio
        def initialize(start_year)
          students = Student.for_year(start_year)

          students_paid = students.joins(:schoolings)
                                  .joins(pfmps: { payment_requests: :asp_payment_request_transitions })
                                  .where("asp_payment_request_transitions.to_state": :paid)
                                  .distinct

          super(
            subset: students_paid,
            all: students.all
          )
        end

        def key
          :students_paid_ratio
        end

        def title
          "Part élèves payés"
        end

        def tooltip_key
          "stats.ratio.students_paid"
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
