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

  def self.seed
    Dir.glob(Rails.root.join("data/mefs/*.csv")).each do |file_path|
      process_file(file_path)
    end

    logger.info "[seeds] done inserting MEF codes."
  end

  private

  def self.process_file(file_path)
    file_name = File.basename(file_path, ".csv")
    start_year = file_name.split("_").first.to_i

    school_year = SchoolYear.find_by!(start_year: start_year)

    if school_year.nil?
      logger.warn "[seeds] School year not found for #{file_name}. Skipping file."
      return
    end

    data = CSV.read(file_path, headers: true)

    mefs = data.map do |entry|
      attributes = MAPPING.transform_values do |value|
        if value == "MINISTERE"
          Mef.ministries[entry[value].downcase]
        else
          entry[value]
        end
      end

      attributes.merge("school_year_id" => school_year.id)
    end

    Mef.upsert_all(mefs, unique_by: :code) # rubocop:disable Rails/SkipsModelValidations

    logger.info "[seeds] Inserted MEF codes for school year #{school_year.start_year}-#{school_year.start_year + 1}."
  end
end
