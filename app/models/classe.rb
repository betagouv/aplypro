# frozen_string_literal: true

class Classe < ApplicationRecord
  belongs_to :establishment
  belongs_to :mef

  has_many :schoolings, dependent: nil
  has_many :students, -> { order "last_name" }, dependent: nil, through: :schoolings
  has_many :pfmps, through: :schoolings

  def create_bulk_pfmp(pfmp_params)
    students.each do |student|
      student.current_schooling.pfmps.create!(pfmp_params)
    end
  end

  def to_s
    "Classe de #{label}"
  end
end
