# frozen_string_literal: true

class ExclusionSeeder
  EXCLUSIONS = [
    "0541769E",
    "0010212A",
    "0930075B",
    %w[0382170C 2472000831],
    %w[0690652J 2472340732],
    %w[0690652J 2472340733],
    %w[0690652J 2412010122],
    %w[0690652J 2412344721],
    %w[0690652J 2412344722],
    %w[0690652J 2412521921],
    %w[0690652J 2412521922],
    %w[0690652J 2412543422],
    %w[0691875N 2473360333],
    %w[0691875N 2473360531],
    %w[0691875N 2473360632],
    %w[0691875N 2413361521],
    %w[0691875N 2413361522],
    %w[0442083A 2473121131],
    %w[0442083A 2473121332],
    %w[0442083A 2473121333],
    %w[0910838S 2473000433],
    %w[0910838S 2473121432],
    %w[0442227G 2403320511 1]
  ].freeze

  def self.seed
    logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

    EXCLUSIONS.each do |uai, mef_code, school_year_id|
      Exclusion.find_or_create_by!(uai:, mef_code:, school_year_id:)
    end

    logger.info { "[seeds] upserted #{Exclusion.count} exclusions" }
  end
end
