# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations, Metrics/AbcSize, Metrics/CyclomaticComplexity
class FixPfmpsPaidPayableRatioKey < ActiveRecord::Migration[8.0]
  def up
    Report.find_each do |report|
      next if report.data.blank?

      data = report.data.deep_dup
      updated = false

      %w[global_data bops_data menj_academies_data establishments_data].each do |data_type|
        next unless data[data_type].is_a?(Array) && data[data_type].length >= 2

        headers = data[data_type][0]
        next unless headers.is_a?(Array)

        index = headers.index(:pfmp_paid_payable_ratio)
        if index
          headers[index] = :pfmps_paid_payable_ratio
          updated = true
        end
      end

      report.update_column(:data, data) if updated
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
# rubocop:enable Rails/SkipsModelValidations, Metrics/AbcSize, Metrics/CyclomaticComplexity
