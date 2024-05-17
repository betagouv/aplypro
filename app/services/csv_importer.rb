# frozen_string_literal: true

class CSVImporter
  module Errors
    class Error < StandardError; end
    class WrongHeaders < Error; end
  end

  HEADERS = [
    "ine",
    "prénom",
    "nom",
    "date_naissance",
    "label_classe",
    "mef_code",
    "année_scolaire",
    "date_début",
    "date_fin",
    "Sexe biologique",
    "Code INSEE de ville de naissance",
    "Code INSEE de pays de naissance",
    "Code postal de résidence",
    "Code INSEE de ville de résidence",
    "Code INSEE de pays de résidence"
  ].freeze

  attr_reader :data, :uai

  def initialize(io, uai)
    @data = CSV.parse(io, col_sep: ";", headers: true)
    @uai = uai

    difference = data.headers.difference(HEADERS)

    raise Errors::WrongHeaders, "headers mismatch: #{difference}" if difference.any?
  end

  def parse!
    Student::Mappers::CSV.new(data, uai).parse!
  end
end
