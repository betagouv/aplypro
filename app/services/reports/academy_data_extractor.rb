# frozen_string_literal: true

module Reports
  class AcademyDataExtractor < BaseExtractor
    def extract_field(field_name)
      data = extract(:menj_academies_data)
      return {} unless data_valid?(data)

      headers = data[0]
      field_index = find_field_index(headers, field_name)
      return {} unless field_index

      build_academy_hash(data, field_index)
    end

    private

    def data_valid?(data)
      data.is_a?(Array) && data.length >= 2 && data[0].is_a?(Array)
    end

    def find_field_index(headers, field_name)
      headers.index(field_name.to_s)
    end

    def build_academy_hash(data, field_index)
      data[1..].each_with_object({}) do |row, result|
        next unless row.is_a?(Array) && row.length > field_index

        academy = row[0]
        value = row[field_index]
        result[academy] = value if academy.present? && value.present?
      end
    end
  end
end
