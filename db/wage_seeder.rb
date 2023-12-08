# frozen_string_literal: true

require "csv"

class WageSeeder
  WAGE_MAPPING = {
    daily_rate: "FORFAIT JOURNALIER",
    yearly_cap: "PLAFOND MAX",
    mefstat4: "MEF_STAT_4",
    ministry: "BOP"
  }.freeze

  # rubocop:disable Metrics/AbcSize
  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    logger.info "[seeds] inserting daily wages by mef..."

    Wage.delete_all

    data = CSV.read(Rails.root.join("data/mefs-amounts.csv"), headers: true)

    wages = data.map { |d| d.fields(*WAGE_MAPPING.values) }.uniq.compact

    duplicated_groups = duplicated_groups(wages, data)

    wages.each do |daily, yearly, mefstat4, ministry, _|
      Wage.find_or_initialize_by(
        mefstat4: mefstat4,
        ministry: Wage.ministries[ministry.downcase],
        daily_rate: daily,
        yearly_cap: yearly,
        mef_codes: duplicated_groups[[daily, yearly, mefstat4, ministry]]
      ).save!
    end

    logger.info "[seeds] done inserting #{wages.length} daily wages by mef."
  end
  # rubocop:enable Metrics/AbcSize

  def self.duplicated_groups(wages, data)
    groups = wages
             .group_by { |_, _, mefstat4, ministry| [mefstat4, ministry] }
             .select { |_, grouped_wages| grouped_wages.count > 1 }
             .reduce([]) { |arr, (_, grouped_wages)| arr + grouped_wages }

    groups.to_h do |daily, yearly, mefstat4, ministry|
      mef_codes = mef_codes_of_group(data, [daily, yearly, mefstat4, ministry])

      [[daily, yearly, mefstat4, ministry], mef_codes]
    end
  end

  def self.mef_codes_of_group(data, group)
    data.map { |d| d.fields(*(["MEF"] + WAGE_MAPPING.values)) }
        .select { |_, daily, yearly, mefstat4, ministry| group == [daily, yearly, mefstat4, ministry] }
        .map { |mef_code, _, _, _, _| mef_code }
  end
end
