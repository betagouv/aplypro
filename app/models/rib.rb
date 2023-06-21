# frozen_string_literal: true

class Rib < ApplicationRecord
  belongs_to :student

  validates :iban, :bic, presence: true

  # courtesy of gem 'bank-account'
  validates :iban, iban: true
  validates :bic, bic: true

  after_create do
    student.rib_changed!
  end

  def safe_iban
    iban.chars.fill("X", 4).join
  end
end
