# frozen_string_literal: true

module ASP
  class PaymentRequestValidator < ActiveModel::Validator
    def validate(request)
      request.errors.add(:validation, :eligibility) unless ASP::StudentFileEligibilityChecker.new(request.student).ready?

      request.errors.add(:validation, :lives_in_france) unless request.student.lives_in_france?

      request.errors.add(:validation, :student_type) unless request.schooling.student?

      request.errors.add(:validation, :rib) unless request.student.rib.valid?

      request.errors.add(:validation, :pfmp) unless request.pfmp.valid?

      request.errors.add(:validation, :ine_not_found) if request.student.ine_not_found

      request.errors.add(:validation, :adult_without_personal_rib) if request.student.adult_without_personal_rib?

      request.errors.add(:validation, :amount) unless request.pfmp.amount.positive?

      request.errors.add(:validation, :attributive_decision) unless request.schooling.attributive_decision.attached?

      request.errors.add(:validation, :duplicates) if request.pfmp.duplicates.any? { |p| p.in_state?(:validated) }
    end
  end
end
