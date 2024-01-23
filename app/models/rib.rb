# frozen_string_literal: true

class Rib < ApplicationRecord
  belongs_to :student

  validates :iban, :bic, :name, presence: true
  validates :student_id, uniqueness: { scope: :archived_at }, if: :active?

  # courtesy of gem 'bank-account'
  validates :iban, iban: true
  validates :bic, bic: true

  scope :active, -> { where.not(archived_at: nil) }

  def active?
    archived_at.blank?
  end

  def inactive?
    !active?
  end
end
