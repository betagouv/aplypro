# frozen_string_literal: true

class Rib < ApplicationRecord
  belongs_to :student

  belongs_to :establishment, optional: true

  enum :owner_type, { personal: 0, other_person: 1, moral_person: 2 }

  has_many :payment_requests, class_name: "ASP::PaymentRequest", dependent: :nullify

  validates :iban, :bic, :name, presence: true

  validates :student_id, uniqueness: { scope: %i[archived_at establishment_id], message: :unarchivable_rib },
                         unless: :archived?

  scope :multiple_ibans, -> { Rib.select(:iban).group(:iban).having("count(iban) > 1") }

  normalizes :bic, :iban, with: ->(value) { value.gsub(/\s+/, "").upcase }
  normalizes :name, with: ->(name) { name.squish }

  before_validation do
    self.iban = Rib.normalize_value_for(:iban, iban) unless iban.nil?
    self.bic = Rib.normalize_value_for(:bic, bic) unless bic.nil?
  end

  # gem 'bank-account' provides the :iban and :rib validation but we
  # have to override the message because they both (the gem and our
  # SEPA format validation) add the :invalid error key to the object,
  # which means we can't choose what message to use if we just rely on
  # Active Record's default translation system.
  validates :iban,
            iban: true,
            format: {
              with: /\A(#{Aplypro::SEPA_IBANS.join('|')})/,
              message: I18n.t("activerecord.errors.models.rib.attributes.iban.sepa")
            }
  validates :bic, bic: true

  scope :archived, -> { where.not(archived_at: nil) }

  def archived?
    archived_at.present?
  end

  def archive!
    update!(archived_at: DateTime.now)
  end

  def archivable?
    payment_requests.empty? || payment_requests.all?(&:terminated?)
  end

  def readonly?
    !archivable?
  end
end
