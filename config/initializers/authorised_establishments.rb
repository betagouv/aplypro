# frozen_string_literal: true

require "csv"

module Aplypro
  AUTHORISED_ESTABLISHMENTS = CSV.read(Rails.root.join("data/authorised-establishments.csv"),
                                       headers: true, return_headers: false).to_a
end
