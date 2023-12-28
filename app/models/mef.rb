# frozen_string_literal: true

class Mef < ApplicationRecord
  enum :ministry, %i[menj masa armee mer]

  validates :label, :code, :short, :mefstat11, :ministry, presence: true
  validates :code, uniqueness: true

  def mefstat4
    mefstat11.slice(0..3)
  end

  def wage
    wages = Wage.where(mefstat4: mefstat4, ministry: ministry)
    return wages.first unless wages.many?

    wages.find { |wage| wage.mef_codes.include? code }
  end

  def bop_code(establishment)
    return ministry if ministry != "menj"

    if establishment.private?
      "enpr"
    elsif establishment.public?
      "enpu"
    else
      raise IdentityMappers::Errors::UnallowedPrivateEstablishment
    end
  end
end
