# frozen_string_literal: true

class Student < ApplicationRecord # rubocop:disable Metrics/ClassLength
  validates :ine,
            :first_name,
            :last_name,
            :birthdate,
            presence: true

  validates :address_city_insee_code, length: { maximum: 5 }, allow_blank: true

  enum :biological_sex, { sex_unknown: 0, male: 1, female: 2 }, validate: { allow_nil: true }, default: :sex_unknown

  has_many :schoolings, dependent: :delete_all

  has_many :classes, through: :schoolings, source: "classe"

  has_many :pfmps, -> { order "pfmps.created_at" }, through: :schoolings

  has_one :current_schooling, -> { current }, class_name: "Schooling", dependent: :destroy, inverse_of: :student

  has_one :classe, through: :current_schooling

  has_one :establishment, through: :classe

  has_many :ribs, dependent: :destroy

  scope :lives_in_france, -> { where(address_country_code: %w[100 99100]) }
  scope :lives_abroad, -> { where.not(id: lives_in_france) }

  scope :ine_not_found, -> { where(ine_not_found: true) }
  scope :with_ine, -> { where(ine_not_found: false) }

  scope :with_biological_sex, -> { where(biological_sex: %i[male female]) }
  scope :with_known_postal_code, -> { where.not(address_postal_code: nil) }

  scope :without_ribs, -> { where.missing(:ribs) }
  scope :with_rib, -> { joins(:ribs).distinct }

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

  scope :for_year, lambda { |start_year|
                     joins(schoolings: { classe: :school_year })
                       .where(school_year: { start_year: start_year })
                       .distinct
                   }

  sourced_from_external_api :birthdate,
                            :address_line1,
                            :address_line2,
                            :address_postal_code,
                            :address_city_insee_code,
                            :address_city,
                            :address_country_code,
                            :birthplace_city_insee_code,
                            :birthplace_country_insee_code,
                            :biological_sex

  def rib(etab_id = establishment&.id)
    ribs.find_by(establishment_id: etab_id, archived_at: nil)
  end

  # NOTE: used in stats for column "Données d'élèves nécessaires présentes"
  def self.asp_ready
    with_ine
      .with_biological_sex
      .with_valid_birthplace
      .with_valid_address
  end

  def lives_in_france?
    InseeCodes.in_france?(address_country_code)
  rescue InseeCountryCodeMapper::UnusableCountryCode
    false
  end

  def transferred?
    multiple_mefs? || multiple_establishments?
  end

  def multiple_mefs?
    classes.current.joins(:mef).select(:"mefs.id").distinct.many?
  end

  def multiple_establishments?
    classes.current.select(:establishment_id).distinct.many?
  end

  def any_classes_in_establishment?(establishment)
    classes.any? { |classe| classe.establishment.eql?(establishment) }
  end

  def to_s
    full_name
  end

  def full_name
    [last_name, first_name].join(" ")
  end

  def duplicates
    normalized_first_name = first_name.tr("-'", " ").squeeze(" ").strip
    normalized_last_name = last_name.tr("-'", " ").squeeze(" ").strip

    Student.where(
      "LOWER(UNACCENT(REGEXP_REPLACE(REGEXP_REPLACE(first_name, '[''\\-]', ' ', 'g'), '\\s+', ' ', 'g'))) = " \
      "LOWER(UNACCENT(?)) AND " \
      "LOWER(UNACCENT(REGEXP_REPLACE(REGEXP_REPLACE(last_name, '[''\\-]', ' ', 'g'), '\\s+', ' ', 'g'))) = " \
      "LOWER(UNACCENT(?)) AND " \
      "birthdate = ? AND " \
      "birthplace_city_insee_code = ?",
      normalized_first_name, normalized_last_name, birthdate, birthplace_city_insee_code
    )
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

  def born_in_france?
    InseeCodes.in_france?(birthplace_country_insee_code)
  end

  def create_new_rib(rib_params)
    current_rib = rib(rib_params.fetch("establishment_id"))
    current_rib.archive! if current_rib.present?
    ribs.create(rib_params)
  end

  def adult_at?(date)
    date >= birthdate + 18.years
  end

  def retry_pfmps_payment_requests!
    pfmps.in_state(:validated).each { |pfmp| PfmpManager.new(pfmp).retry_payment_request! }
  end

  def first_names
    [first_name, first_name2, first_name3].compact.join(", ")
  end

  def last_schooling
    @last_schooling ||= schoolings.includes(classe: :establishment)
                                  .order(end_date: :desc, start_date: :desc)
                                  .first
  end
end
