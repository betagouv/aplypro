# frozen_string_literal: true

class Classe < ApplicationRecord
  belongs_to :establishment
  belongs_to :mef

  has_many :schoolings, dependent: :destroy

  has_many :students, -> { order("last_name", "first_name") }, dependent: nil, through: :schoolings

  has_many :pfmps, through: :schoolings

  has_many :attributive_decisions_attachments,
           through: :schoolings,
           source: :attributive_decision_attachment

  has_many :active_schoolings,
           -> { current },
           dependent: :destroy,
           class_name: "Schooling",
           inverse_of: :classe

  has_many :inactive_schoolings,
           -> { former },
           dependent: :destroy,
           class_name: "Schooling",
           inverse_of: :classe

  has_many :active_students,
           -> { order("last_name", "first_name") },
           class_name: "Student",
           through: :active_schoolings,
           source: :student

  has_many :inactive_students,
           -> { order("last_name", "first_name") },
           class_name: "Student",
           through: :inactive_schoolings,
           source: :student

  has_many :active_pfmps, through: :active_schoolings, class_name: "Pfmp", source: :pfmps

  validates :label, :start_year, presence: true
  validates :start_year, numericality: { only_integer: true }

  scope :current, -> { where(start_year: Aplypro::SCHOOL_YEAR) }
  scope :with_attributive_decisions, -> { joins(schoolings: :attributive_decision_attachment) }

  def create_bulk_pfmp(pfmp_params)
    Pfmp.transaction do
      schoolings.current.each do |schooling|
        schooling.pfmps.create!(pfmp_params)
      end
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def to_s
    "Classe de #{label}"
  end

  def to_long_s
    [label, mef.label].join(" - ")
  end

  def schooling_of(student)
    schoolings.find_by(student: student)
  end

  def closed_schooling_of(student_id)
    closed_schoolings_per_student_id[student_id]
  end

  private

  def closed_schoolings_per_student_id
    @closed_schoolings_per_student_id ||= inactive_schoolings.index_by(&:student_id)
  end
end
