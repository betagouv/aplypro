# frozen_string_literal: true

class Classe < ApplicationRecord
  belongs_to :establishment
  belongs_to :mef

  has_many :schoolings, dependent: nil
  has_many :students, -> { order "last_name" }, dependent: nil, through: :schoolings
  has_many :pfmps, through: :schoolings
  has_many :attributive_decisions_attachments, through: :schoolings, source: :attributive_decision_attachment

  validates :label, :start_year, presence: true
  validates :start_year, numericality: { only_integer: true, greater_than_or_equal_to: 2023 }

  scope :current, -> { where(start_year: ENV.fetch("APLYPRO_SCHOOL_YEAR")) }
  scope :with_attributive_decisions, -> { joins(schoolings: :attributive_decision_attachment) }

  def create_bulk_pfmp(pfmp_params)
    @pfmp = Pfmp.new(pfmp_params)

    Pfmp.transaction do
      students.each do |student|
        student.current_schooling.pfmps.create!(pfmp_params)
      end
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def to_s
    "Classe de #{label}"
  end

  def to_long_s
    [label, mef.specialty].join(" - ")
  end
end
