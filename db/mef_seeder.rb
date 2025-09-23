# frozen_string_literal: true

require "csv"

# For the introduction of a new SchoolYear
# First create the new SchoolYear so that SchoolYear.current returns the latest one
# Then run MefSeeder.seed
class MefSeeder
  MAPPING = {
    code: "MEF",
    mefstat11: "MEF_STAT_11",
    short: "LIBELLE_COURT",
    label: "LIBELLE_LONG",
    ministry: "MINISTERE"
  }.freeze

  def self.seed(file_paths = nil)
    @@logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

    paths = file_paths || Rails.root.glob("data/mefs/*.csv")

    Mef.transaction do
      paths.each do |file_path|
        process_file(file_path)
      end
    end

    @@logger.info "[seeds] upserted #{Mef.count} total MEFs"
  end

  private

  def self.process_file(file_path)
    file_name = File.basename(file_path, ".csv")
    start_year = file_name.split("_").first.to_i

    school_year = SchoolYear.find_by!(start_year: start_year)

    data = CSV.read(file_path, headers: true)

    mefs = data.map do |entry|
      attributes = MAPPING.transform_values do |value|
        if value == "MINISTERE"
          Mef.ministries[entry[value].downcase]
        else
          entry[value]
        end
      end

      attributes.merge(school_year_id: school_year.id)
    rescue StandardError => e
      raise "Problem at line #{entry}"
    end

    duplicates = mefs.group_by { |mef| [mef[:code], mef[:school_year_id]] }
                   .select { |_, group| group.size > 1 }

    if duplicates.any?
      @@logger.warn "[seeds] found duplicates in MEF data for school year #{school_year}"
      duplicates.each do |key, group|
        @@logger.warn "[seeds] duplicate found for code: #{key[0]} and school_year_id: #{key[1]}"
      end
    end

    Mef.upsert_all(mefs, unique_by: [:code, :school_year_id]) # rubocop:disable Rails/SkipsModelValidations

    @@logger.info "[seeds] upserted #{mefs.size} MEFs for school year: #{school_year}"
  end
end
