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
      check_insee_code
      check_address
      check_da_attribution
      check_da_abrogation
      check_rib
      check_pfmp
      check_duplicates
      check_schooling
    end

    private

    def check_student
      add_error(:missing_biological_sex) if student.sex_unknown?

      add_error(:doesnt_live_in_france) unless student.lives_in_france?

      add_error(:ine_not_found) if student.ine_not_found
    end

    def check_rib
      add_error(:missing_rib) and return if rib.blank?

      add_error(:rib) if rib.invalid?

      add_error(:adult_without_personal_rib) if student.adult_without_personal_rib?
    end

    def check_pfmp
      add_error(:pfmp) unless pfmp.valid?

      add_error(:pfmp_amount) unless pfmp.amount.positive?
    end

    def check_schooling
      add_error(:student_type) if !payment_request.schooling.student?

      add_error(:excluded_schooling) if payment_request.schooling.excluded?
    end

    def check_da_attribution
      add_error(:missing_attributive_decision) if !payment_request.schooling.attributive_decision.attached?
    end

    def check_da_abrogation
      if !student.transferred? || (payment_request.schooling.abrogated? && payment_request.pfmp.within_schooling_dates?)
        return
      end

      other_schoolings = student.schoolings.excluding(payment_request.schooling)

      return if other_schoolings.all?(&:abrogated?)

      add_error(:needs_abrogated_attributive_decision)
    end

    def check_insee_code
      add_error(:missing_birthplace_country_insee_code) if student.birthplace_country_insee_code.blank?

      return unless student.born_in_france? && student.birthplace_city_insee_code.blank?

      add_error(:missing_birthplace_city_insee_code)
    end

    def check_duplicates
      add_error(:duplicates) if pfmp.duplicates.any? do |p|
        p.in_state?(:validated)
      end
    end

    def check_address
      %i[address_postal_code address_city_insee_code address_country_code].each do |info|
        add_error(:"missing_#{info}") if student[info].blank?
      end
    end

    def add_error(description)
      payment_request.errors.add(:ready_state_validation, description)
    end

    def student
      @student ||= payment_request.student
    end

    def rib
      @rib ||= student.rib
    end

    def pfmp
      @pfmp ||= payment_request.pfmp
    end
  end
end
