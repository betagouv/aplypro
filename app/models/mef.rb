# frozen_string_literal: true

class Mef < ApplicationRecord
  enum :ministry, %i[menj masa armee mer]

  validates :label, :code, :short, :mefstat11, :ministry, presence: true
  validates :code, uniqueness: true

  has_one :wage, dependent: :destroy

  def mefstat4
    mefstat11.slice(0..3)
  end

  def bop_code(establishment)
    return ministry if ministry != "menj"

    if establishment.private_allowed?
      "enpr"
    elsif establishment.public?
      "enpu"
    else
      raise IdentityMappers::Errors::UnallowedPrivateEstablishment
    end
  end
end
