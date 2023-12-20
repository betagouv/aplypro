# frozen_string_literal: true

class Student < ApplicationRecord
  validates :ine,
            :first_name,
            :last_name,
            :birthdate,
            :asp_file_reference,
            presence: true

  validates :asp_file_reference, uniqueness: true

  has_many :schoolings, dependent: :delete_all

  has_many :classes, through: :schoolings, source: "classe"

  has_many :pfmps, -> { order "pfmps.start_date" }, through: :schoolings

  has_one :current_schooling, -> { current }, class_name: "Schooling", dependent: :destroy, inverse_of: :student

  has_one :classe, through: :current_schooling

  has_one :establishment, through: :classe

  has_many :payments, through: :pfmps

  has_many :ribs, dependent: :destroy

  has_one :rib, -> { where(archived_at: nil) }, dependent: :destroy, inverse_of: :student

  scope :with_rib, -> { joins(:rib) }

  scope :with_address, lambda {
    where.not(address_line1: nil)
         .or(where.not(address_line2: nil))
         .where.not(postal_code: nil)
         .where.not(country_code: nil)
         .where.not(city: nil)
  }

  before_validation :check_asp_file_reference

  ADDRESS_FIELDS = %i[
    address_line1
    address_line2
    postal_code
    city
  ].freeze

  def to_s
    full_name
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def index_name
    [last_name, first_name].join(" ")
  end

  def used_allowance
    payments.in_state(:success).map(&:amount).sum
  end

  def allowance_left
    current_schooling.mef.wage.yearly_cap - used_allowance
  end

  def close_current_schooling!(date = Time.zone.today)
    current_schooling&.update!(end_date: date)
  end

  def address
    ADDRESS_FIELDS.map { |field| self[field] }.compact.join(", ")
  end

  def missing_address?
    address.blank?
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
