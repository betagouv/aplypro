# frozen_string_literal: true

class Statistics < ApplicationRecord
  scope :academy, -> { where.not(bop: nil).where.not(academy_code: nil).where.not(academy_label: nil) }
  scope :bop, -> { where.not(bop: nil).where(academy_code: nil, academy_label: nil) }
  scope :establishment, -> { where(bop: nil).where.not(academy_code: nil).where.not(academy_label: nil) }
  scope :global, -> { where(bop: nil, academy_code: nil, academy_label: nil) }

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_school_year, ->(school_year) { where(school_year: school_year) }

  class << self
    def create_for_year(school_year) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      start_year = school_year.start_year

      schoolings = Schooling.for_year(start_year)
      students = Student.for_year(start_year)
      pfmps = Pfmp.for_year(start_year)
      payment_requests = ASP::PaymentRequest.for_year(start_year).joins(:asp_payment_request_transitions)

      Statistics.create!(
        school_year: school_year,
        bop: "",
        academy_code: "",
        academy_label: "",
        schoolings: schoolings.count,
        edited_da: schoolings.with_attributive_decisions.count,
        students: students.count,
        students_with_rib: students.with_rib.count,
        students_with_data: students.asp_ready.count,
        pfmps: pfmps.count,
        validated_pfmps: pfmps.finished.in_state(:validated).count,
        validated_pfmps_amount: "",
        completed_pfmps: "",
        completed_pfmps_amount: "",
        incomplete_pfmps: "",
        theoretical_incomplete_pfmps_amount: "",
        invalid_pfmps: "",
        theoretical_invalid_pfmps_amount: "",
        asp_payments_paid: payment_requests.where("asp_payment_request_transitions.to_state": :paid).count,
        asp_payments_paid_amount: "",
        paid_students: "",
        paid_pfmps: "",
        payable_pfmps: "",
        reported_da: "",
        reported_da_amount: ""
      )
    end
  end

  def edited_da_percentage
    edited_da.percent_of(schoolings)
  end

  def students_with_rib_percentage
    students_with_rib.percent_of(students)
  end

  def students_with_data_percentage
    students_with_data.percent_of(students)
  end

  def paid_students_percentage
    paid_students.percent_of(students)
  end

  def paid_pfmps_percentage
    paid_pfmps.percent_of(payable_pfmps)
  end
end
