# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations, Metrics/AbcSize
class MigrateReportDataToSymbolKeys < ActiveRecord::Migration[8.0]
  OLD_HEADERS = ["DA", "Coord. bancaires", "PFMPs validées", "Données élèves", "Mt. prêt envoi",
                 "Mt. annuel total", "Scolarités", "Toutes PFMPs", "Dem. envoyées", "Dem. intégrées",
                 "Dem. payées", "Mt. payé", "Ratio PFMPs payées/payables"].freeze

  NEW_HEADERS = %i[
    yearly_sum schoolings_count attributive_decisions_count attributive_decisions_ratio
    students_count ribs_count ribs_ratio students_data_count students_data_ratio pfmps_count
    pfmps_validated_count pfmps_validated_sum pfmps_completed_count pfmps_completed_sum
    pfmps_incompleted_count pfmps_incompleted_sum payment_requests_paid_count
    payment_requests_paid_sum payment_requests_recovery_sum students_paid_count
    students_paid_ratio pfmps_paid_count pfmps_payable_count pfmp_paid_payable_ratio
    pfmps_extended_count pfmps_extended_sum
  ].freeze

  def up
    Report.class_eval do
      attr_accessor :skip_schema_validation

      before_validation { self.skip_schema_validation = true }
    end

    Report.find_each do |report|
      next if report.data.blank? || report.data.dig("global_data", 0, 0).is_a?(Symbol)

      report.update_column(:data, migrate_report_data(report.data))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def migrate_report_data(data)
    {
      "global_data" => migrate_array(data["global_data"], []),
      "bops_data" => migrate_array(data["bops_data"], [:bop]),
      "menj_academies_data" => migrate_array(data["menj_academies_data"], [:academy]),
      "establishments_data" => migrate_array(data["establishments_data"],
                                             %i[uai establishment_name ministry academy private_or_public])
    }
  end

  def migrate_array(array_data, prefix_keys)
    return array_data if array_data.blank? || array_data.length < 2
    return array_data if array_data[0].first.is_a?(Symbol)

    [prefix_keys + NEW_HEADERS, *array_data[1..].map { |row| migrate_row(row, prefix_keys.length) }]
  end

  def migrate_row(row, prefix_count)
    return row if row.blank?

    prefix = row[0...prefix_count]
    old_values = row[prefix_count...(prefix_count + OLD_HEADERS.length)] || []
    old_values = old_values.ljust(OLD_HEADERS.length, nil) if old_values.length < OLD_HEADERS.length
    new_values = Array.new(NEW_HEADERS.length, nil)

    { 0 => 5, 1 => 6, 2 => 0, 5 => 1, 7 => 3, 9 => 7, 10 => 2, 11 => 4,
      16 => 8, 17 => 10, 18 => 11, 24 => 12 }.each { |new_idx, old_idx| new_values[new_idx] = old_values[old_idx] }

    prefix + new_values
  end
end
# rubocop:enable Rails/SkipsModelValidations, Metrics/AbcSize
