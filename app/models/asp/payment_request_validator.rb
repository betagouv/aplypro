# frozen_string_literal: true

module ASP
  class PaymentRequestValidator < ActiveModel::Validator
    attr_reader :payment_request

    def initialize(payment_request)
      super()
      @payment_request = payment_request
    end

    def validate
      check_student
      check_attributive_decision
      check_rib
      check_pfmp
      check_duplicates
      check_schooling
    end

    private

    def check_student
      unless ASP::StudentFileEligibilityChecker.new(student).ready?
        add_error(
          :eligibility
        )
      end

      add_error(:lives_in_france) unless student.lives_in_france?

      add_error(:ine_not_found) if student.ine_not_found
    end

    def check_rib
      add_error(:rib) unless student.rib.present? && student.rib.valid?

      return unless student.adult_without_personal_rib?

      add_error(:adult_without_personal_rib)
    end

    def check_pfmp
      add_error(:pfmp) unless pfmp.valid?
      add_error(:pfmp_amount) unless pfmp.amount.positive?
    end

    def check_schooling
      add_error(:excluded_schooling) if payment_request.schooling.excluded?
    end

    def check_attributive_decision
      return if payment_request.schooling.attributive_decision.attached?

      add_error(:missing_attributive_decision)

      add_error(:needs_abrogated_attributive_decision) if student.needs_abrogated_attributive_decision?
    end

    def check_duplicates
      add_error(:duplicates) if pfmp.duplicates.any? do |p|
        p.in_state?(:validated)
      end
    end

    def add_error(description)
      payment_request.errors.add(:ready_state_validation, description)
    end

    def student
      @student ||= payment_request.student
    end

    def pfmp
      @pfmp ||= payment_request.pfmp
    end
  end
end
