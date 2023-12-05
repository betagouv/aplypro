# frozen_string_literal: true

require "csv"

class WageMefstat4Seeder
  WAGE_MAPPING = {
    daily_rate: "FORFAIT JOURNALIER",
    yearly_cap: "PLAFOND MAX",
    mefstat4: "MEF_STAT_4"
  }.freeze

  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    logger.info "[seeds] inserting daily wages..."

    data = CSV.read(Rails.root.join("data/mefs-amounts.csv"), headers: true)

    wages = data.map { |d| d.fields(*WAGE_MAPPING.values) }.uniq.compact

    wages.each do |daily, yearly, code|
      Wage.find_or_initialize_by(
        mefstat4: code,
        daily_rate: daily,
        yearly_cap: yearly
      ).save!
    end

    logger.info "[seeds] done inserting daily wages."
  end
end
