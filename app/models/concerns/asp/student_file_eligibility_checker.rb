# frozen_string_literal: true

module ASP
  class StudentFileEligibilityChecker
    attr_reader :student

    DATA_REQUIREMENTS = %i[rib birthplace_information address_information biological_sex].freeze

    def initialize(student)
      @student = student
    end

    def ready?
      DATA_REQUIREMENTS.all? { |requirement| can_provide?(requirement) }
    end

    private

    def attributes_present?(attributes)
      attributes.all? { |attr| student.send(attr).present? }
    end

    def can_provide?(requirement)
      case requirement
      when :rib
        student.rib.present?
      when :birthplace_information
        required_attributes = [:birthplace_country_insee_code]

        required_attributes.push(:birthplace_city_insee_code) if student.born_in_france?

        attributes_present?(required_attributes)
      when :address_information
        attributes_present? %i[address_postal_code address_city_insee_code address_country_code]
      when :biological_sex
        student.male? || student.female?
      else
        raise ArgumentError, "don't know how to check for #{requirement}"
      end
    end
  end
end
