# frozen_string_literal: true

require "csv"

module Establishment
  AUTHORISED_COLLEGES_UAIS = CSV.read(Rails.root.join("data/authorised-establishments.csv"),
                                      headers: true, return_headers: false).to_a
end
