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
    @@logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

    Mef.transaction do
      Dir.glob(Rails.root.join("data/mefs/*.csv")).each do |file_path|
        process_file(file_path)
      end
    end

    @@logger.info "[seeds] done inserting MEF codes."
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
    end

    duplicates = mefs.group_by { |mef| [mef[:code], mef[:school_year_id]] }
                   .select { |_, group| group.size > 1 }

    puts duplicates
    if duplicates.any?
      @@logger.warn "[seeds] Found duplicates in MEF data for school year #{school_year.start_year}-#{school_year.start_year + 1}:"
      duplicates.each do |key, group|
        @@logger.warn "  Duplicate for code: #{key[0]}, school_year_id: #{key[1]}"
      end
    end

    # Mef.upsert_all(mefs, unique_by: [:code, :school_year_id]) # rubocop:disable Rails/SkipsModelValidations

    @@logger.info "[seeds] Inserted MEF codes for school year #{school_year.start_year}-#{school_year.start_year + 1}."
  end
end
