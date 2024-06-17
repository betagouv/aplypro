# frozen_string_literal: true

class Schooling < ApplicationRecord
  has_one_attached :attributive_decision
  has_one_attached :abrogation_decision

  enum :status, { student: 0, apprentice: 1, other: 2 }, validate: { allow_nil: true }

  belongs_to :student
  belongs_to :classe

  has_many :pfmps, -> { order("pfmps.created_at" => :asc) }, dependent: :destroy, inverse_of: :schooling
  has_many :payment_requests, through: :pfmps

  has_one :mef, through: :classe
  has_one :establishment, through: :classe

  scope :current, -> { where(end_date: nil) }
  scope :former, -> { where.not(end_date: nil) }

  scope :with_attributive_decisions, -> { joins(:attributive_decision_attachment) }
  scope :without_attributive_decisions, -> { where.missing(:attributive_decision_attachment) }
  scope :generating_attributive_decision, -> { where(generating_attributive_decision: true) }
  scope :with_administrative_number, -> { where.not(administrative_number: nil) }

  # https://github.com/betagouv/aplypro/issues/792
  scope :with_one_character_attributive_decision_version, -> { where("schoolings.attributive_decision_version < 10") }

  validates :student, uniqueness: { scope: :end_date, message: :unique_active_schooling }, if: :open?
  validates :student, uniqueness: { scope: :classe }, if: :closed?

  updatable :start_date, :end_date, :status

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

  def abrogated?
    closed? && abrogation_decision.attached?
  end

  def reopen!
    update!(end_date: nil)
  end

  def open?
    !closed?
  end

  def excluded?
    Exclusion.excluded?(establishment.uai, mef.code)
  end

  def attachment_file_name(description)
    [
      student.last_name,
      student.first_name,
      description,
      attributive_decision_number
    ].join("_").concat(".pdf")
  end

  def attributive_decision_key(filename)
    [
      establishment.uai,
      Aplypro::SCHOOL_YEAR,
      classe.label.parameterize,
      filename
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

  def attach_attributive_document(output, attachment_name)
    raise "Unsupported attachment type" unless %i[attributive_decision abrogation_decision].include?(attachment_name)

    description = attachment_name == :attributive_decision ? "décision-d-attribution" : "décision-d-abrogation"
    name = attachment_file_name(description)

    attachment = public_send(attachment_name)
    attachment.purge if attachment.present?

    attachment.attach(
      io: output,
      key: attributive_decision_key(name),
      filename: name,
      content_type: "application/pdf"
    )
  end
end
