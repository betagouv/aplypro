# frozen_string_literal: true

# by Stephane

module ASP
  class PaymentRequestValidator < ActiveModel::Validator
    def validate(request)
      check_student(request)
      check_rib(request)
      check_other(request)
    end

    def check_other(request)
      unless request.schooling.attributive_decision.attached?
        request.errors.add(:ready_state_validation,
                           :attributive_decision)
      end
      request.errors.add(:ready_state_validation, :duplicates) if request.pfmp.duplicates.any? do |p|
                                                                    p.in_state?(:validated)
                                                                  end
    end

    def check_pfmp(request)
      request.errors.add(:ready_state_validation, :pfmp) unless request.pfmp.valid?
      request.errors.add(:ready_state_validation, :pfmp_amount) unless request.pfmp.amount.positive?
    end

    def check_student(request)
      request.errors.add(:ready_state_validation, :ine_not_found) if request.student.ine_not_found

      return if ASP::StudentFileEligibilityChecker.new(request.student).ready?

      request.errors.add(:ready_state_validation,
                         :eligibility)
    end

    def check_rib(request)
      request.errors.add(:ready_state_validation, :rib) unless request.student&.rib&.valid?
      return unless request.student.adult_without_personal_rib?

      request.errors.add(:ready_state_validation,
                         :adult_without_personal_rib)
    end
  end
end
