# frozen_string_literal: true

class Establishment < ApplicationRecord # rubocop:disable Metrics/ClassLength
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

  belongs_to :confirmed_director, class_name: "User", optional: true

  has_many :classes, -> { order "classes.label" }, class_name: "Classe", dependent: :destroy, inverse_of: :establishment

  has_many :schoolings, through: :classes
  has_many :active_schoolings, through: :classes

  has_many :students, through: :schoolings

  has_many :pfmps, -> { reorder nil }, through: :classes
  has_many :active_pfmps, -> { reorder nil }, through: :classes

  has_many :payment_requests, -> { reorder nil }, through: :pfmps

  validate :ensure_confirmed_director_is_director

  # List of establishment types : https://infocentre.pleiade.education.fr/bcn/workspace/viewTable/n/N_TYPE_UAI
  ACCEPTED_ESTABLISHMENT_TYPES = %w[LYC LP SEP EREA CFPA EME IMP CONT].freeze

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
    "ministere_tutelle" => :ministry,
    "code_departement" => :department_code
  }.freeze

  # Find all codes here : https://infocentre.pleiade.education.fr/bcn/workspace/viewTable/n/N_CONTRAT_ETABLISSEMENT
  CONTRACTS_STATUS = {
    public: ["99"],
    private_allowed: %w[30 31 40 41 60]
  }.freeze

  SCHOOL_YEAR_RANGE_EXCEPTIONS = {
    "43" => Date.new(Aplypro::SCHOOL_YEAR, 8, 23), # Mayotte
    "28" => Date.new(Aplypro::SCHOOL_YEAR, 8, 16) # La Réunion
  }.freeze

  class << self
    def accepted_type?(type)
      ACCEPTED_ESTABLISHMENT_TYPES.include?(type)
    end
  end

  # NOTE: this method could fetch the actual data per academie if we stored that information
  #       this was implemented as a hotfix for La Réunion and Mayotte
  def school_year_range
    start_date = SCHOOL_YEAR_RANGE_EXCEPTIONS.fetch(academy_code, Aplypro::DEFAULT_SCHOOL_YEAR_START)
    (start_date..start_date >> 12)
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

  def students_api
    StudentsApi.api_for(students_provider)
  end

  def rattach_attributive_decisions_zip!(content, filename)
    attributive_decisions_zip.purge if attributive_decisions_zip.present?

    attributive_decisions_zip.attach(
      io: content,
      filename: filename,
      content_type: "application/zip"
    )
  end

  def excluded?
    Exclusion.establishment_excluded?(uai)
  end

  def contract_type
    case private_contract_type_code
    when *CONTRACTS_STATUS[:private_allowed]
      :private
    when *CONTRACTS_STATUS[:public]
      :public
    else
      :other
    end
  end

  def some_attributive_decisions?
    schoolings.with_attributive_decisions.any?
  end

  def missing_attributive_decisions?
    schoolings.without_attributive_decisions.any?
  end

  def has_attributive_decisions?
    schoolings.with_attributive_decisions.any?
  end

  def some_attributive_decisions_generating?
    schoolings.generating_attributive_decision.any?
  end

  def validatable_pfmps
    validatable_pfmps_ids = pfmps.in_state(:completed).select do |pfmp|
      pfmp.can_transition_to?(:validated)
    end.map(&:id)
    pfmps.where(id: validatable_pfmps_ids)
  end

  def ensure_confirmed_director_is_director
    return if !confirmed_director || establishment_user_roles.find_by({ user: confirmed_director }).dir?

    errors.add :confirmed_director, "is not a director"
  end
end
