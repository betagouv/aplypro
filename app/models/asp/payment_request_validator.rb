# frozen_string_literal: true

module ASP
  class PaymentRequestValidator < ActiveModel::Validator
    attr_reader :payment_request

    def validate(payment_request)
      @payment_request = payment_request

      check_student
      check_attributive_decision
      check_rib
      check_pfmp
      check_duplicates
    end

    private

    def check_student
      unless ASP::StudentFileEligibilityChecker.new(student).ready?
        payment_request.errors.add(:ready_state_validation,
                                   :eligibility)
      end

      payment_request.errors.add(:ready_state_validation, :lives_in_france) unless student.lives_in_france?

      payment_request.errors.add(:ready_state_validation, :ine_not_found) if student.ine_not_found
    end

    def check_rib
      payment_request.errors.add(:ready_state_validation, :rib) unless student&.rib&.valid?

      return unless student.adult_without_personal_rib?

      payment_request.errors.add(:ready_state_validation,
                                 :adult_without_personal_rib)
    end

    def check_pfmp
      payment_request.errors.add(:ready_state_validation, :pfmp) unless pfmp.valid?
      payment_request.errors.add(:ready_state_validation, :pfmp_amount) unless pfmp.amount.positive?
    end

    def check_attributive_decision
      return if payment_request.schooling.attributive_decision.attached?

      payment_request.errors.add(:ready_state_validation,
                                 :attributive_decision)
    end

    def check_duplicates
      payment_request.errors.add(:ready_state_validation, :duplicates) if pfmp.duplicates.any? do |p|
        p.in_state?(:validated)
      end
    end

    def student
      @student ||= payment_request.student
    end

    def pfmp
      @pfmp ||= payment_request.pfmp
    end
  end
end
