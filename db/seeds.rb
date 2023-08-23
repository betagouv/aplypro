# frozen_string_literal: true

require "csv"

logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

logger.info "[seeds] inserting MEF codes..."

data = CSV.read(Rails.root.join("data/mefs.csv"), headers: true)

MAPPING = {
  code: "MEF",
  mefstat11: "MEF_STAT_11",
  short: "LIBELLE_COURT",
  label: "LIBELLE_LONG",
  ministry: "MINISTERE"
}.freeze

data.each do |entry|
  code = entry[MAPPING[:code]]

  mef = Mef.find_or_initialize_by(code:)

  attributes = MAPPING.transform_values do |value|
    if value == "MINISTERE"
      Mef.ministries[entry[value].downcase]
    else
      entry[value]
    end
  end

  mef.update!(attributes)
end

logger.info "[seeds] done inserting MEF codes."

logger.info "[seeds] inserting daily wages..."

data = CSV.read(Rails.root.join("data/mefs-amounts.csv"), headers: true)

WAGE_MAPPING = {
  daily_rate: "FORFAIT JOURNALIER",
  yearly_cap: "PLAFOND MAX",
  mefstat4: "MEF_STAT_4"
}.freeze

wages = data.map { |d| d.fields(*WAGE_MAPPING.values) }.uniq.compact

wages.each do |daily, yearly, code|
  Wage.find_or_initialize_by(
    mefstat4: code,
    daily_rate: daily,
    yearly_cap: yearly
  ).save!
end

logger.info "[seeds] done inserting daily wages."
