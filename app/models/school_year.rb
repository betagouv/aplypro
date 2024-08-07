# frozen_string_literal: true

class SchoolYear < ApplicationRecord
  validates :start_year, presence: true, uniqueness: true, numericality: { only_integer: true }

  has_many :classes,
           class_name: "Classe",
           dependent: :nullify,
           inverse_of: :school_year

  def self.current
    order(start_year: :asc).last
  end

  def end_year
    start_year + 1
  end

  def to_s
    "#{start_year}-#{end_year}"
  end

  def to_param
    start_year.to_s
  end
end
