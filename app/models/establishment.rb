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

  has_many :students, through: :schoolings

  API_MAPPING = {
    "nom_etablissement" => :name,
    "libelle_nature" => :denomination,
    "code_academie" => :academy_code,
    "libelle_academie" => :academy_label,
    "adresse_1" => :address_line1,
    "adresse_2" => :address_line2,
    "code_postal" => :postal_code,
    "nom_commune" => :city,
    "telephone" => :telephone,
    "mail" => :email,
    "code_type_contrat_prive" => :private_contract_type_code,
    "ministere_tutelle" => :ministry
  }.freeze

  # Find all codes here : https://infocentre.pleiade.education.fr/bcn/workspace/viewTable/n/N_CONTRAT_ETABLISSEMENT
  CONTRACTS_STATUS = {
    public: ["99"],
    private_allowed: %w[30 31 40 41]
  }.freeze

  def current_schoolings
    schoolings.current
  end

  def to_s
    [uai, name, city, postal_code].compact.join(" – ")
  end

  def invites?(email)
    invitations.exists?(email: email)
  end

  def select_label
    [uai, name].compact.join(" - ")
  end

  def address
    [address_line1, address_line2, postal_code, city].join(", ")
  end

  def rattach_attributive_decisions_zip!(content, filename)
    attributive_decisions_zip.purge if attributive_decisions_zip.present?

    attributive_decisions_zip.attach(
      io: content,
      filename: filename,
      content_type: "application/zip"
    )
  end

  def contract_type
    case private_contract_type_code
    when *CONTRACTS_STATUS[:private_allowed]
      :private_allowed
    when *CONTRACTS_STATUS[:public]
      :public
    else
      :other
    end
  end

  def private_allowed?
    contract_type == :private_allowed
  end

  def public?
    contract_type == :public
  end

  def some_attributive_decisions?
    current_schoolings.with_attributive_decisions.any?
  end

  def missing_attributive_decisions?
    current_schoolings.without_attributive_decisions.any?
  end

  def some_attributive_decisions_generating?
    current_schoolings.generating_attributive_decision.any?
  end
end
