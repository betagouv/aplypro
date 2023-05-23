# frozen_string_literal: true

class Classe < ApplicationRecord
  belongs_to :establishment
  belongs_to :mefstat
  has_many :students, dependent: :destroy

  def to_s
    "Classe de #{label}"
  end
end
