# frozen_string_literal: true

module ASP
  class PaymentRequestValidator < ActiveModel::Validator
    attr_reader :payment_request

    def initialize(payment_request)
      super()
      @payment_request = payment_request
    end

    def validate
      check_funding
      check_student
      check_insee_code
      check_address
      check_da_attribution
      check_da_abrogation
      check_da_cancellation
      check_rib
      check_pfmp
      check_pfmp_overlaps
      check_schooling
    end

    private

    def check_funding
      classe = payment_request.pfmp.classe
      ministry = classe.mef.ministry
      contract_type_code = classe.establishment.private_contract_type_code

      if (ministry.eql?("masa") || (ministry.eql?("menj") && !contract_type_code.eql?(99))) && !Rails.env.test?
        add_error(:insufficient_funds)
      end
    end

    def check_student
      add_error(:missing_biological_sex) if student.sex_unknown?

      add_error(:ine_not_found) if student.ine_not_found
    end

    def check_rib
      add_error(:missing_rib) and return if rib.nil?

      add_error(:rib) if rib.invalid?

      return unless student.adult_at?(pfmp.start_date) && (rib.other_person? || rib.moral_person?)

      add_error(:adult_wrong_owner_type)
    end

    def check_pfmp
      add_error(:pfmp) unless pfmp.valid?
      add_error(:pfmp_amount) if pfmp.amount.nil? || pfmp.amount <= 0
    end

    def check_schooling
      add_error(:student_type) if !payment_request.schooling.student?

      add_error(:excluded_schooling) if payment_request.schooling.excluded?
    end

    def check_da_attribution
      add_error(:missing_attributive_decision) if !payment_request.schooling.attributive_decision.attached?
    end

    def check_da_cancellation
      add_error(:attributive_decision_cancelled) if payment_request.schooling.cancelled?
    end

    def check_da_abrogation # rubocop:disable Metrics/AbcSize
      if !student.transferred? || (payment_request.schooling.abrogated? && payment_request.pfmp.within_schooling_dates?)
        return
      end

      other_schoolings = student.schoolings.excluding(payment_request.schooling).to_a.select do |sc|
        sc.classe.school_year == payment_request.schooling.classe.school_year
      end

      return if other_schoolings.all?(&:abrogated?)

      add_error(:needs_abrogated_attributive_decision)
    end

    def check_insee_code
      add_error(:missing_birthplace_country_insee_code) if student.birthplace_country_insee_code.blank?

      return unless student.born_in_france? && student.birthplace_city_insee_code.blank?

      add_error(:missing_birthplace_city_insee_code)
    rescue InseeCountryCodeMapper::UnusableCountryCode
      add_error(:unusable_birthplace_country_insee_code)
    end

    def check_pfmp_overlaps
      add_error(:overlaps) if pfmp.overlaps.any? do |p|
        p.in_state?(:validated)
      end
    end

    def check_address
      add_error(:missing_address_country_code) if student.address_country_code.blank?

      return unless student.lives_in_france?

      %i[address_postal_code address_city_insee_code].each do |info|
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
      @rib ||= payment_request.rib_with_fallback
    end

    def pfmp
      @pfmp ||= payment_request.pfmp
    end
  end
end
