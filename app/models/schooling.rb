# frozen_string_literal: true

class Schooling < ApplicationRecord
  has_one_attached :attributive_decision

  belongs_to :student
  belongs_to :classe

  has_many :pfmps, dependent: :destroy

  has_one :mef, through: :classe
  has_one :establishment, through: :classe

  after_create do
    if student.current_schooling.present? && student.current_schooling != self
      student.current_schooling.update!(end_date: Time.zone.now)
    end

    student.update!(current_schooling: self)
  end

  def attributive_decision_filename
    [
      student.first_name,
      student.last_name,
      "décision-d-attribution",
      Time.zone.today
    ].join("_").concat(".pdf")
  end

  def rattach_attributive_decision!(output)
    name = attributive_decision_filename

    attributive_decision.purge if attributive_decision.present?

    attributive_decision.attach(
      io: output,
      key: [Rails.env, name].join("/"),
      filename: name,
      content_type: "application/pdf"
    )
  end
end
