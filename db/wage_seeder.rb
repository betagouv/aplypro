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

    data = CSV.read(Rails.root.join("data/wages/2023_2024.csv"), headers: true)

    data
      .group_by { |d| d.fields(*WAGE_MAPPING.values) }
      .each do |group, wages|
        daily, yearly, mefstat4, ministry = group

        Wage.create(
          mefstat4: mefstat4,
          ministry: Wage.ministries[ministry.downcase],
          daily_rate: daily,
          yearly_cap: yearly,
          mef_codes: wages.pluck("MEF")
        )
      end

    logger.info "[seeds] done inserting #{Wage.count} daily wages by mef."
  end
  # rubocop:enable Metrics/AbcSize
end
