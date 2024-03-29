# frozen_string_literal: true

require "csv"

module Aplypro
  # extracted from:
  #
  # https://www.europeanpaymentscouncil.eu/sites/default/files/kb/file/2023-01/EPC409-09%20EPC%20List%20of%20SEPA%20Scheme%20Countries%20v4.0.pdf
  SEPA_COUNTRIES = CSV.read(Rails.root.join("data/sepa-zone-countries.csv"), headers: true)

  SEPA_IBANS = SEPA_COUNTRIES.pluck("IBAN")
end
