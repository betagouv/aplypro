# frozen_string_literal: true

class Establishment < ApplicationRecord
  self.primary_key = :uai

  validates :name, :uai, presence: true
  validates :uai, uniqueness: true

  BOOTSTRAP_URL = ENV.fetch("APLYPRO_ESTABLISHMENTS_BOOTSTRAP_URL")

  CSV_MAPPING = {
    "numero_uai" => :uai,
    "appellation_officielle" => :name,
    "denomination_principale" => :denomination,
    "nature_uai" => :nature
  }.freeze

  def self.from_csv(csv)
    attributes = CSV_MAPPING.to_h do |col, attr|
      [attr, csv[col]]
    end

    Establishment.new(attributes)
  end

  def second_degree?
    nature.start_with?("3")
  end
end
