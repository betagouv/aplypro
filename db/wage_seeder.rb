# frozen_string_literal: true

require "csv"

class WageSeeder
  WAGE_MAPPING = {
    daily_rate: "FORFAIT JOURNALIER",
    yearly_cap: "PLAFOND MAX",
    mefstat4: "MEF_STAT_4",
    ministry: "BOP"
  }.freeze

  def self.seed
    @@logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

    Wage.transaction do
      Dir.glob(Rails.root.join("data/wages/*.csv")).each do |file_path|
        process_file(file_path)
      end
    end

    @@logger.info "[seeds] upserted #{Wage.count} total wages"
  end

  private

  def self.process_file(file_path)
    file_name = File.basename(file_path, ".csv")
    start_year = file_name.split("_").first.to_i

    school_year = SchoolYear.find_by!(start_year: start_year)

    data = CSV.read(file_path, headers: true)

    wages = data.group_by { |d| d.fields(*WAGE_MAPPING.values) }
                .map do |group, entries|
      daily, yearly, mefstat4, ministry = group
      {
        mefstat4: mefstat4,
        ministry: Wage.ministries[ministry.downcase],
        daily_rate: daily.to_i,
        yearly_cap: yearly.to_i,
        mef_codes: entries.pluck("MEF"),
        school_year_id: school_year.id
      }
    end

    Wage.upsert_all(
      wages
    )

    @@logger.info "[seeds] upserted wages for school year #{school_year.start_year}-#{school_year.start_year + 1}"
  end
end
