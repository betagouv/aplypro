# frozen_string_literal: true

module ReportValidation
  extend ActiveSupport::Concern

  included do
    validate :validate_report_structure, unless: -> { Rails.env.test? && skip_schema_validation }
  end

  def validate_report_structure
    return if data.blank?

    result = Report::ReportDataSchema.call(data)
    return process_schema_errors(result) if result.failure?

    validate_data_structures
  end

  def validate_data_structures
    validate_array_structure(:global_data, self.class::HEADERS)
    validate_array_structure(:bops_data, [:bop] + self.class::HEADERS)
    validate_array_structure(:menj_academies_data, [:academy] + self.class::HEADERS)
    establishment_keys = %i[uai establishment_name ministry academy private_or_public]
    validate_array_structure(:establishments_data, establishment_keys + self.class::HEADERS)
  end

  def process_schema_errors(result)
    result.errors.each do |error|
      errors.add(:data, "#{error.path.join('.')} #{error.text}")
    end
  end

  def validate_array_structure(key, expected_headers)
    array_data = data[key.to_s]
    return unless array_data.is_a?(Array) && array_data.any?

    validate_header(key, array_data, expected_headers)
    validate_row_sizes(key, array_data, expected_headers)
  end

  def validate_header(key, array_data, expected_headers)
    actual_headers = array_data.first.map { |h| h.is_a?(String) ? h.to_sym : h }
    normalized_expected = expected_headers.map { |h| h.is_a?(String) ? h.to_sym : h }
    return if actual_headers == normalized_expected

    errors.add(:data, "#{key} header must be #{expected_headers}")
  end

  def validate_row_sizes(key, array_data, expected_headers)
    array_data.each_with_index do |row, index|
      next if index.zero? || row.size == expected_headers.length

      errors.add(:data, "#{key} row #{index} must have #{expected_headers.length} elements")
    end
  end
end
