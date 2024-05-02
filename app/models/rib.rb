# frozen_string_literal: true

class Rib < ApplicationRecord
  belongs_to :student

  validates :iban, :bic, :name, presence: true
  validates :student_id, uniqueness: { scope: :archived_at }, if: :active?
  validate :can_be_updated?, on: :update

  scope :multiple_ibans, -> { Rib.select(:iban).group(:iban).having("count(iban) > 1") }

  normalizes :bic, :iban, with: ->(value) { value.gsub(/\s+/, "").upcase }
  normalizes :name, with: ->(name) { name.squish }

  before_validation do
    self.iban = Rib.normalize_value_for(:iban, iban) unless iban.nil?
    self.bic = Rib.normalize_value_for(:bic, bic) unless bic.nil?
  end

  before_destroy :can_be_deleted?, prepend: true

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

  scope :active, -> { where.not(archived_at: nil) }

  def active?
    archived_at.blank?
  end

  def inactive?
    !active?
  end

  private

  def locked?
    student.pfmps.any?(&:locked?)
  end

  def can_be_updated?
    return false if student.nil?

    errors.add(:base, :locked) if locked?
  end

  def can_be_deleted?
    # using `return unless locked?` is awkward
    if locked? # rubocop:disable Style/GuardClause
      errors.add(:base, :locked)

      throw :abort
    end
  end
end
