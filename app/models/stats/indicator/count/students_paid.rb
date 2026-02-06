# frozen_string_literal: true

module Stats
  module Indicator
    module Count
      class StudentsPaid < Stats::Count
        def initialize(start_year)
          super(
            all: Schooling.for_year(start_year)
                 .joins(pfmps: { payment_requests: :asp_payment_request_transitions })
                 .where(asp_payment_request_transitions: { most_recent: true, to_state: "paid" })
                 .select(:student_id)
                 .distinct
          )
        end

        def self.key
          :students_paid_count
        end

        def self.title
          "Nb. élèves payés"
        end

        def self.tooltip_key
          "stats.count.students_paid"
        end

        def with_mef_and_establishment
          Schooling.joins(classe: %i[mef establishment])
        end

        def with_establishment
          Schooling.joins(classe: :establishment)
        end
      end
    end
  end
end
