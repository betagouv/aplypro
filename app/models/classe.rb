# frozen_string_literal: true

class Classe < ApplicationRecord
  belongs_to :establishment
  belongs_to :mefstat

  has_many :students, -> { order "last_name" }, dependent: :destroy, inverse_of: :classe
  has_many :pfmps, through: :students

  def to_s
    "Classe de #{label}"
  end
end
