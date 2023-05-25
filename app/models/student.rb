# frozen_string_literal: true

class Student < ApplicationRecord
  self.primary_key = "ine"

  validates :ine, :first_name, :last_name, presence: true

  belongs_to :classe
  has_one :establishment, through: :classe
  has_many :pfmps, dependent: :destroy

  SYGNE_MAPPING = {
    "prenom" => :first_name,
    "nom" => :last_name,
    "ine" => :ine
  }.freeze

  def to_s
    full_name
  end

  def full_name
    [first_name, last_name].join("  ")
  end

  def self.from_sygne_hash(hash)
    attributes = SYGNE_MAPPING.to_h do |attr, col|
      [col, hash[attr]]
    end

    Student.new(attributes)
  end
end
