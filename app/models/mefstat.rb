# frozen_string_literal: true

class Mefstat < ApplicationRecord
  BOOTSTRAP_URL = ENV.fetch "APLYPRO_MEFSTATS_BOOTSTRAP_URL"

  CSV_MAPPING = {
    "mef_stat_4" => :code,
    "libelle_court" => :short,
    "libelle_long" => :label
  }.freeze

  validates :label, :code, :short, presence: true
  validates :code, uniqueness: true

  def self.from_csv(csv)
    attributes = CSV_MAPPING.to_h do |col, attr|
      [attr, csv[col]]
    end

    Mefstat.new(attributes)
  end
end
