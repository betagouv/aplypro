# frozen_string_literal: true

require "csv"

class WageSeeder
  WAGE_MAPPING = {
    daily_rate: "FORFAIT JOURNALIER",
    yearly_cap: "PLAFOND MAX",
    mef_code: "MEF"
  }.freeze

  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    logger.info "[seeds] inserting daily wages by mef..."

    data = CSV.read(Rails.root.join("data/mefs-amounts.csv"), headers: true)

    wages = data.map { |d| d.fields(*WAGE_MAPPING.values) }

    wages.each do |daily, yearly, mef_code|
      Wage.find_or_initialize_by(
        mef_code: mef_code,
        daily_rate: daily,
        yearly_cap: yearly
      ).save!
    end

    logger.info "[seeds] done inserting #{wages.length} daily wages by mef."
  end
end
