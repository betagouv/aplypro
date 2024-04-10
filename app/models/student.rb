# frozen_string_literal: true

class Student < ApplicationRecord
  validates :ine,
            :first_name,
            :last_name,
            :birthdate,
            :asp_file_reference,
            presence: true

  validates :asp_file_reference, uniqueness: true

  enum :biological_sex, { unknown: 0, male: 1, female: 2 }, validate: { allow_nil: true }, default: :unknown

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
  scope :ine_not_found, -> { where(ine_not_found: true) }
  scope :with_ine, -> { where(ine_not_found: false) }
  scope :with_biological_sex, -> { where(biological_sex: %i[male female]) }
  scope :with_known_birthplace, -> { where.not(birthplace_country_insee_code: nil) }
  scope :with_valid_birthplace, lambda {
    with_known_birthplace
      .where.not(birthplace_country_insee_code: InseeCountryCodeMapper::REJECTED_CODES.keys)
  }

  def self.asp_ready
    joins(:rib)
      .lives_in_france
      .with_ine
      .with_biological_sex
      .with_valid_birthplace
  end

  before_validation :check_asp_file_reference

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
    adult? && !rib.personal?
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
