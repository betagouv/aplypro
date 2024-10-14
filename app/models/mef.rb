# frozen_string_literal: true

class Mef < ApplicationRecord
  enum :ministry, %i[menj masa armee mer]

  belongs_to :school_year

  scope :with_wages, -> { joins("JOIN wages ON wages.mef_codes ? mefs.code") }

  validates :label, :code, :short, :mefstat11, :ministry, presence: true
  validates :code, uniqueness: { scope: :school_year_id }

  def mefstat4
    mefstat11.slice(0..3)
  end

  def wage
    wages = Wage.where(mefstat4: mefstat4, ministry: ministry, school_year: school_year)
    return wages.first unless wages.many?

    wages.find { |wage| wage.mef_codes.include? code }
  end

  def bop(establishment)
    code = if menj?
             "menj_#{establishment.contract_type}"
           else
             ministry
           end

    code.to_sym
  end
end
