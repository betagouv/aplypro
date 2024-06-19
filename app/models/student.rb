# frozen_string_literal: true

class Student < ApplicationRecord # rubocop:disable Metrics/ClassLength
  validates :ine,
            :first_name,
            :last_name,
            :birthdate,
            :asp_file_reference,
            presence: true

  validates :asp_file_reference, uniqueness: true

  enum :biological_sex, { sex_unknown: 0, male: 1, female: 2 }, validate: { allow_nil: true }, default: :sex_unknown

  has_many :schoolings, dependent: :delete_all

  has_many :classes, through: :schoolings, source: "classe"

  has_many :pfmps, -> { order "pfmps.created_at" }, through: :schoolings

  has_one :current_schooling, -> { current }, class_name: "Schooling", dependent: :destroy, inverse_of: :student

  has_one :classe, through: :current_schooling

  has_one :establishment, through: :classe

  has_many :ribs, dependent: :destroy

  has_one :rib, -> { where(archived_at: nil) }, dependent: :destroy, inverse_of: :student

  scope :without_ribs, -> { where.missing(:rib) }
  scope :lives_in_france, -> { where(address_country_code: %w[100 99100]) }
  scope :lives_abroad, -> { where.not(address_country_code: %w[100 99100]) }
  scope :ine_not_found, -> { where(ine_not_found: true) }
  scope :with_ine, -> { where(ine_not_found: false) }
  scope :with_biological_sex, -> { where(biological_sex: %i[male female]) }
  scope :with_known_postal_code, -> { where.not(address_postal_code: nil) }
  scope :with_rib, -> { joins(:rib) }

  scope :with_known_birthplace, -> { where.not(birthplace_country_insee_code: nil) }
  scope :with_valid_birthplace, lambda {
    with_known_birthplace
      .with_valid_birthplace_city
      .where.not(birthplace_country_insee_code: InseeCountryCodeMapper::REJECTED_CODES.keys)
  }

  scope :with_known_address, -> { where.not(address_country_code: nil) }
  scope :with_valid_address, lambda {
    with_known_address
      .with_known_postal_code
      .with_valid_address_city
      .where.not(address_country_code: InseeCountryCodeMapper::REJECTED_CODES.keys)
  }

  scope :with_city_code, -> { where.not(address_city_insee_code: nil) }
  scope :with_valid_address_city, -> { lives_in_france.with_city_code.or(lives_abroad) }

  scope :with_valid_birthplace_city, lambda {
    where.not(
      "students.birthplace_country_insee_code IN (?) AND students.birthplace_city_insee_code IS NULL",
      %w[100 99100]
    )
  }

  updatable :address_line1,
            :address_postal_code,
            :address_city_insee_code,
            :address_country_code,
            :birthplace_city_insee_code,
            :birthplace_country_insee_code,
            :biological_sex

  # NOTE: used in stats for column "Données d'élèves nécessaires présentes"
  def self.asp_ready
    with_ine
      .with_biological_sex
      .with_valid_birthplace
      .with_valid_address
  end

  before_validation :check_asp_file_reference

  # FIXME: this is used to filter the payment requests but at some
  # point we should stop doing it, once we've done the work to offer
  # abrogated attributive decisions.
  def transferred?
    multiple_mefs? || multiple_establishments?
  end

  def multiple_mefs?
    classes.joins(:mef).select(:"mefs.id").distinct.count > 1
  end

  def multiple_establishments?
    classes.select(:establishment_id).distinct.count > 1
  end

  def to_s
    full_name
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def index_name
    [last_name, first_name].join(" ")
  end

  def close_current_schooling!(date = Time.zone.today)
    current_schooling&.update!(end_date: date)
  end

  def address
    [
      address_line1,
      address_line2,
      address_postal_code,
      address_city
    ].compact.join(", ")
  end

  def missing_address?
    address.blank?
  end

  def underage?
    birthdate > 18.years.ago
  end

  def adult?
    !underage?
  end

  def adult_without_personal_rib?
    return false if underage? || rib.blank?

    !rib.personal?
  end

  def born_in_france?
    InseeCodes.in_france?(birthplace_country_insee_code)
  end

  def lives_in_france?
    return false if address_country_code.blank?

    InseeCodes.in_france?(address_country_code)
  rescue InseeCountryCodeMapper::UnusableCountryCode
    false
  end

  private

  def check_asp_file_reference
    return if asp_file_reference.present?

    loop do
      self.asp_file_reference = generate_asp_file_reference

      break unless Student.exists?(asp_file_reference: asp_file_reference)
    end
  end

  def generate_asp_file_reference
    SecureRandom.alphanumeric(10).upcase
  end
end
