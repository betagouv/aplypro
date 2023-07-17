# frozen_string_literal: true

class Mef < ApplicationRecord
  validates :label, :code, :short, presence: true
  validates :code, uniqueness: true

  def mefstat4
    mefstat11.slice(0..3)
  end
end
