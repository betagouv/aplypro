# frozen_string_literal: true

class Mef < ApplicationRecord
  enum :ministry, %i[menj masa armee mer]

  validates :label, :code, :short, :mefstat11, :ministry, presence: true
  validates :code, uniqueness: true

  def mefstat4
    mefstat11.slice(0..3)
  end

  def to_s
    [code, short, label].join(" - ")
  end
end
