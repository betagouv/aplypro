# frozen_string_literal: true

class SchoolYear < ApplicationRecord
  validates :start_year, presence: true, uniqueness: true
  validates :start_year, numericality: { only_integer: true }

  has_many :classes,
           class_name: "Classe",
           dependent: :nullify,
           inverse_of: :school_year

  def self.current
    order(start_year: :asc).last
  end

  def self.default_school_start_date
    Date.new(current.start_year, 9, 1)
  end

  def end_year
    start_year + 1
  end
end
