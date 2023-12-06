# frozen_string_literal: true

require "csv"

class WageSeeder
  WAGE_MAPPING = {
    daily_rate: "FORFAIT JOURNALIER",
    yearly_cap: "PLAFOND MAX",
    mef_code: "MEF"
  }.freeze

  # rubocop:disable Metrics/AbcSize
  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    logger.info "[seeds] inserting daily wages by mef..."

    data = CSV.read(Rails.root.join("data/mefs-amounts.csv"), headers: true)

    wages = data.map { |d| d.fields(*WAGE_MAPPING.values) }
    mef_ids_per_code = Mef.pluck(:code, :id).to_h

    wages.each do |daily, yearly, mef_code|
      mef_id = mef_ids_per_code[mef_code]
      next unless mef_id

      Wage.find_or_initialize_by(
        mef_id: mef_id,
        daily_rate: daily,
        yearly_cap: yearly
      ).save!
    end

    logger.info "[seeds] done inserting #{wages.length} daily wages by mef."
  end
  # rubocop:enable Metrics/AbcSize
end
