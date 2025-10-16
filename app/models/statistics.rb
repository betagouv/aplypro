# frozen_string_literal: true

class Statistics < ApplicationRecord
  belongs_to :school_year

  scope :academy, -> { initialize_scope(true, false, true) }
  scope :bop, -> { initialize_scope(false, true, true) }
  scope :establishment, -> { initialize_scope(false, true, false) }
  scope :global, -> { initialize_scope(false, false, false) }

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_year, lambda { |start_year|
    joins(classe: :school_year)
      .where(school_year: { start_year: start_year })
  }

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

  class << self
    def create_for_year(start_year) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      schoolings = Schooling.for_year(start_year)
      students = Student.for_year(start_year)
      pfmps = Pfmp.for_year(start_year)
      paid_pfmps = PaidPfmp.paid # TODO: .for_year(start_year) ?
      payment_requests = ASP::PaymentRequest.for_year(start_year).joins(:asp_payment_request_transitions)

      Statistics.create!(
        school_year: SchoolYear.find_by(start_year:),
        bop: "",
        academy_code: "",
        academy_label: "",
        establishment_uai: "",
        establishment_name: "",
        schoolings: schoolings.count,
        edited_da: schoolings.with_attributive_decisions.count,
        students: students.count,
        students_with_rib: students.with_rib.count,
        students_with_data: students.asp_ready.count,
        pfmps: pfmps.count,
        validated_pfmps: pfmps.finished.in_state(:validated).count,
        validated_pfmps_amount: "",
        completed_pfmps: pfmps.in_state(:completed).count,
        completed_pfmps_amount: "",
        incomplete_pfmps: pfmps.in_state(:incomplete).count,
        theoretical_incomplete_pfmps_amount: "",
        invalid_pfmps: "",
        theoretical_invalid_pfmps_amount: "",
        asp_payments_paid: payment_requests.in_state(:paid).count,
        asp_payments_paid_amount: "",
        paid_students: paid_pfmps.distinct.count(:student_id),
        paid_pfmps: paid_pfmps.count,
        payable_pfmps: pfmps.select(&:payable?),
        reported_da: "",
        reported_da_amount: ""
      )
    end

    def initialize_scope(bop, establishment, academy)
      scope = Statistics.all

      bop ? scope.where.not(bop: nil) : scope.where(bop: nil)

      if establishment
        scope.where.not(establishment_name: nil).where.not(establishment_uai: nil)
      else
        scope.where(establishment_name: nil, establishment_uai: nil)
      end

      if academy
        scope.where.not(academy_code: nil).where.not(academy_label: nil)
      else
        scope.where(academy_code: nil, academy_label: nil)
      end

      scope
    end
  end
end
