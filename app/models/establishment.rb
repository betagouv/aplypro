# frozen_string_literal: true

class Establishment < ApplicationRecord
  self.primary_key = "uai"

  validates :uai, presence: true, uniqueness: true

  has_one :principal, dependent: :nullify
  has_many :classes, class_name: "Classe", dependent: :destroy

  after_create :queue_refresh

  API_MAPPING = {
    "nom_etablissement" => :name,
    "libelle_nature" => :denomination,
    "code_postal" => :postal_code,
    "nom_commune" => :city
  }.freeze

  def to_s
    [name, city.capitalize, postal_code].join(" – ")
  end

  def queue_refresh
    FetchEstablishmentJob.perform_later(self)
  end

  def fetch_data!
    raw = EstablishmentApi.fetch!(uai)

    data = raw["records"].first["fields"]

    attributes = API_MAPPING.to_h do |col, attr|
      [attr, data[col]]
    end

    update!(attributes)
  end
end
