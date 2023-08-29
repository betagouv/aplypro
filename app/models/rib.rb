# frozen_string_literal: true

class Rib < ApplicationRecord
  belongs_to :student

  validates :iban, :bic, :name, presence: true

  # courtesy of gem 'bank-account'
  validates :iban, iban: true
  validates :bic, bic: true

  def safe_iban
    iban.chars.fill("X", 4).join
  end
end
