# frozen_string_literal: true

class Establishment < ApplicationRecord
  validates :uai, presence: true, uniqueness: true

  has_many :invitations, dependent: :nullify

  has_many :establishment_user_roles, dependent: :destroy

  has_many :users, through: :establishment_user_roles do
    def authorised
      where(establishment_user_roles: { role: :authorised })
    end

    def directors
      where(establishment_user_roles: { role: :dir })
    end
  end

  has_many :classes, -> { order "label" }, class_name: "Classe", dependent: :destroy, inverse_of: :establishment
  has_many :schoolings, through: :classes

  after_create :queue_refresh

  API_MAPPING = {
    "nom_etablissement" => :name,
    "libelle_nature" => :denomination,
    "code_postal" => :postal_code,
    "nom_commune" => :city,
    "telephone" => :telephone,
    "mail" => :email
  }.freeze

  def to_s
    return "" if no_data?

    [name, city.capitalize, postal_code].join(" – ")
  end

  def invites?(email)
    invitations.exists?(email: email)
  end

  def attributive_decisions
    classes
      .current
      .includes(:schoolings)
      .flat_map(&:attributive_decisions_attachments)
  end

  def never_generated_attributive_decisions?
    attributive_decisions.none?
  end

  def no_data?
    !refreshed?
  end

  def refreshed?
    name.present?
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

  def select_label
    [uai, name].join(" - ")
  end
end
