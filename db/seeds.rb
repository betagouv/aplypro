# frozen_string_literal: true

require 'csv'

data = CSV.read(Rails.root.join("data/mefs.csv"), headers: true)

data.each do |entry|
  code, mefstat11, short, label = entry.values_at("MEF", "MEF_STAT_11", "LIBELLE_COURT", "LIBELLE_LONG")

  mef = Mef.find_or_initialize_by(code: code)

  mef.update!(mefstat11:, short:, label:)
end
