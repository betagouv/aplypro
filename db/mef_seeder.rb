# frozen_string_literal: true

require "csv"

class MefSeeder
  MAPPING = {
    code: "MEF",
    mefstat11: "MEF_STAT_11",
    short: "LIBELLE_COURT",
    label: "LIBELLE_LONG",
    ministry: "MINISTERE"
  }.freeze

  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    logger.info "[seeds] inserting MEF codes..."

    data = CSV.read(Rails.root.join("data/mefs/2024_2025.csv"), headers: true)

    mefs = data.map do |entry|
      attributes = MAPPING.transform_values do |value|
        if value == "MINISTERE"
          Mef.ministries[entry[value].downcase]
        else
          entry[value]
        end
      end

      attributes.merge("school_year_id" => SchoolYear.current.id)
    end

    Mef.upsert_all(mefs, unique_by: :code) # rubocop:disable Rails/SkipsModelValidations

    logger.info "[seeds] done inserting MEF codes."
  end
end
