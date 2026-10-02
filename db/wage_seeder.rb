# frozen_string_literal: true
# rubocop:disable all
require "csv"

class WageSeeder
  class InvalidCsvError < StandardError; end

  WAGE_MAPPING = {
    daily_rate: "FORFAIT JOURNALIER",
    yearly_cap: "PLAFOND MAX",
    mefstat4: "MEF_STAT_4",
    ministry: "BOP"
  }.freeze
  REQUIRED_HEADERS = (["MEF"] + WAGE_MAPPING.values).freeze

  def self.seed(file_paths = nil)
    @@logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

    paths = file_paths || Rails.root.glob("data/wages/*.csv")

    Wage.transaction do
      paths.each do |file_path|
        process_file(file_path)
      end
    end

    @@logger.info "[seeds] upserted #{Wage.count} total wages"
  end

  def self.process_file(file_path)
    file_name = File.basename(file_path, ".csv")
    start_year = file_name.split("_").first.to_i

    school_year = SchoolYear.find_by!(start_year: start_year)

    data = CSV.read(file_path, headers: true)
    validate_data!(data, file_path)

    wages = data.group_by { |row| WAGE_MAPPING.values.map { |header| row[header].strip } }
                .map do |group, entries|
      daily, yearly, mefstat4, ministry = group
      {
        mefstat4: mefstat4,
        ministry: Wage.ministries.fetch(ministry.downcase),
        daily_rate: parse_integer(daily),
        yearly_cap: parse_integer(yearly),
        mef_codes: entries.map { |entry| entry["MEF"].strip },
        school_year_id: school_year.id
      }
    end

    Wage.upsert_all(
      wages,
      unique_by: %i[mefstat4 ministry daily_rate yearly_cap school_year_id]
    )

    @@logger.info "[seeds] upserted wages for school year #{school_year.start_year}-#{school_year.start_year + 1}"
  end

  def self.validate_data!(data, file_path)
    missing_headers = REQUIRED_HEADERS - data.headers
    unless missing_headers.empty?
      raise InvalidCsvError, "#{file_path}: missing required headers: #{missing_headers.join(", ")}"
    end

    raise InvalidCsvError, "#{file_path}: CSV contains no wage rows" if data.empty?

    data.each.with_index(2) do |entry, line_number|
      validate_entry!(entry, file_path, line_number)
    end
  end

  def self.validate_entry!(entry, file_path, line_number)
    %w[MEF MEF_STAT_4 BOP].each do |header|
      next if entry[header].to_s.strip.present?

      raise InvalidCsvError, "#{file_path}: line #{line_number} has no #{header}"
    end

    ministry = entry["BOP"].strip.downcase
    unless Wage.ministries.key?(ministry)
      raise InvalidCsvError, "#{file_path}: line #{line_number} has an unknown BOP: #{entry["BOP"]}"
    end

    ["FORFAIT JOURNALIER", "PLAFOND MAX"].each do |header|
      value = parse_integer(entry[header])
      next if value&.positive?

      raise InvalidCsvError, "#{file_path}: line #{line_number} has an invalid #{header}: #{entry[header].inspect}"
    end
  end

  def self.parse_integer(value)
    Integer(value.to_s.strip, 10, exception: false)
  end
end
