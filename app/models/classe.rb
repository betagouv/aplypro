# frozen_string_literal: true

class Classe < ApplicationRecord
  belongs_to :establishment
  belongs_to :mef

  has_many :students, -> { order "last_name" }, dependent: :destroy, inverse_of: :classe
  has_many :pfmps, through: :students

  def create_bulk_pfmp(pfmp_params)
    students.each do |student|
      student.pfmps.create(pfmp_params)
    end
  end

  def to_s
    "Classe de #{label}"
  end
end
