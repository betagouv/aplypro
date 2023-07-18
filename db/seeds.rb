# frozen_string_literal: true

require "csv"

data = CSV.read(Rails.root.join("data/mefs.csv"), headers: true)

MAPPING = {
  code: "MEF",
  mefstat11: "MEF_STAT_11",
  short: "LIBELLE_COURT",
  label: "LIBELLE_LONG",
  ministry: "MINISTERE"
}.freeze

data.each do |entry|
  code = entry[MAPPING["code"]]

  mef = Mef.find_or_initialize_by(code:)

  attributes = MAPPING.transform_values do |k, v|
    [k, entry[v]]
  end

  mef.update!(attributes)
end
