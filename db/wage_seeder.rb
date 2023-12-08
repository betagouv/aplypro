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

    data = CSV.read(Rails.root.join("data/mefs-amounts.csv"), headers: true)

    wages = data.map { |d| d.fields(*WAGE_MAPPING.values) }.uniq.compact

    wages.each do |daily, yearly, mefstat4, ministry|
      Wage.find_or_initialize_by(
        mefstat4: mefstat4,
        ministry: Wage.ministries[ministry.downcase],
        daily_rate: daily,
        yearly_cap: yearly
      ).save!
    end

    logger.info "[seeds] done inserting #{wages.length} daily wages by mef."
  end
  # rubocop:enable Metrics/AbcSize
end
