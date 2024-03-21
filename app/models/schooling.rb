# frozen_string_literal: true

class Schooling < ApplicationRecord
  has_one_attached :attributive_decision

  belongs_to :student
  belongs_to :classe

  has_many :pfmps, -> { order("pfmps.created_at" => :asc) }, dependent: :destroy, inverse_of: :schooling

  has_one :mef, through: :classe
  has_one :establishment, through: :classe

  scope :current, -> { where(end_date: nil) }
  scope :former, -> { where.not(end_date: nil) }

  scope :with_attributive_decisions, -> { joins(:attributive_decision_attachment) }
  scope :without_attributive_decisions, -> { where.missing(:attributive_decision_attachment) }
  scope :generating_attributive_decision, -> { where(generating_attributive_decision: true) }

  validates :student, uniqueness: { scope: :end_date }, if: :open?
  validates :student, uniqueness: { scope: :classe }, if: :closed?

  def generate_administrative_number
    return if administrative_number.present?

    loop do
      self.administrative_number = SecureRandom.alphanumeric(10).upcase

      break unless Schooling.exists?(administrative_number: administrative_number)
    end
  end

  def closed?
    end_date.present?
  end

  def reopen!
    update!(end_date: nil)
  end

  def open?
    !closed?
  end

  def attributive_decision_filename
    [
      student.last_name,
      student.first_name,
      "décision-d-attribution",
      attributive_decision_number
    ].join("_").concat(".pdf")
  end

  def attributive_decision_key
    [
      establishment.uai,
      Aplypro::SCHOOL_YEAR,
      classe.label.parameterize,
      attributive_decision_filename
    ].join("/")
  end

  def attributive_decision_number
    [
      attributive_decision_bop_indicator,
      administrative_number,
      Aplypro::SCHOOL_YEAR,
      attributive_decision_version
    ].join.upcase
  end

  def bop_code
    mef.bop(establishment)
  end

  def attributive_decision_bop_indicator
    case code = bop_code
    when :menj_private
      "enpr"
    when :menj_public
      "enpu"
    else
      code
    end
  end

  def rattach_attributive_decision!(output)
    name = attributive_decision_filename

    attributive_decision.purge if attributive_decision.present?

    attributive_decision.attach(
      io: output,
      key: attributive_decision_key,
      filename: name,
      content_type: "application/pdf"
    )
  end
end
