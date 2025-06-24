# frozen_string_literal: true

class Schooling < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_one_attached :attributive_decision
  has_one_attached :abrogation_decision
  has_one_attached :cancellation_decision

  enum :status, { student: 0, apprentice: 1, other: 2 }, scopes: false, validate: { allow_nil: true }

  belongs_to :student
  belongs_to :classe

  has_many :pfmps, -> { order("pfmps.created_at" => :asc) }, dependent: :destroy, inverse_of: :schooling
  has_many :payment_requests, through: :pfmps

  has_one :mef, through: :classe
  has_one :establishment, through: :classe

  scope :former, -> { where("schoolings.end_date IS NOT NULL AND schoolings.end_date <= ?", Date.current) }
  scope :active, -> { where("schoolings.end_date IS NULL OR schoolings.end_date > ?", Date.current) }
  scope :removed, -> { where.not(removed_at: nil) }

  scope :current, -> { active.without_removed_students }
  scope :without_removed_students, -> { where(removed_at: nil) }

  scope :with_attributive_decisions, lambda {
    without_cancellation_decisions.without_removed_students.joins(:attributive_decision_attachment)
  }
  scope :without_attributive_decisions, lambda {
    without_removed_students.where.missing(:attributive_decision_attachment)
  }
  scope :generating_attributive_decision, lambda {
    without_removed_students.where(generating_attributive_decision: true)
  }

  scope :without_cancellation_decisions, -> { where.missing(:cancellation_decision_attachment) }
  scope :with_administrative_number, -> { where.not(administrative_number: nil) }

  scope :for_year, lambda { |start_year|
    joins(classe: :school_year)
      .where(school_year: { start_year: start_year })
  }

  # https://github.com/betagouv/aplypro/issues/792
  scope :with_one_character_attributive_decision_version, -> { where("schoolings.attributive_decision_version < 10") }

  validates :student, uniqueness: { scope: :end_date, message: :unique_active_schooling }, if: :open?
  validates :student, uniqueness: { scope: :classe }, if: :closed?

  # NOTE: removed this validation because Sygne doesnt care about SchoolYear end_date validation
  # validates :end_date,
  #           :start_date,
  #           if: ->(schooling) { schooling.classe.present? },
  #           inclusion: {
  #             in: lambda { |schooling|
  #               schooling.establishment.school_year_range(
  #                 schooling.classe.school_year.start_year,
  #                 schooling.extended_end_date || Date.new(schooling.classe.school_year.end_year, 12, 31)
  #               )
  #             }
  #           },
  #           allow_nil: true

  validates :end_date,
            comparison: { greater_than_or_equal_to: :start_date },
            if: -> { start_date && end_date }

  validates :extended_end_date,
            comparison: { greater_than: :end_date },
            if: -> { end_date && extended_end_date }

  sourced_from_external_api :start_date, :end_date, :status

  before_create -> { generate_administrative_number }

  def generate_administrative_number
    return if administrative_number.present?

    loop do
      self.administrative_number = SecureRandom.alphanumeric(10).upcase

      break unless Schooling.exists?(administrative_number: administrative_number)
    end
  end

  def closed?
    end_date.present? && end_date <= Date.current
  end

  def nullified?
    abrogated? || cancelled?
  end

  def abrogated?
    closed? && abrogation_decision.attached?
  end

  def cancelled?
    cancellation_decision.attached?
  end

  def reopen!
    update!(end_date: nil)
  end

  def open?
    !closed?
  end

  def no_dates?
    start_date.blank? && end_date.blank?
  end

  def max_end_date
    extended_end_date || end_date
  end

  def any_extended_pfmp?(date = nil)
    comparison_date = date || end_date
    return false if comparison_date.nil?

    pfmps.any? { |pfmp| pfmp.end_date >= comparison_date }
  end

  def removable_extended_end_date?
    extended_end_date.present? && !any_extended_pfmp?
  end

  def excluded?
    Exclusion.excluded?(establishment.uai, mef.code, classe.school_year)
  end

  def remove!(date = Date.current)
    update!(removed_at: date)
  end

  def removed?
    removed_at.present?
  end

  def syncable?
    !student.ine_not_found && !removed? && establishment.students_provider != "csv"
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
      classe.school_year.start_year,
      classe.label.parameterize,
      filename
    ].join("/")
  end

  def attributive_decision_number
    [
      attributive_decision_bop_indicator,
      administrative_number,
      classe.school_year.start_year,
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
    descriptions = {
      attributive_decision: "décision-d-attribution",
      abrogation_decision: "décision-d-abrogation",
      cancellation_decision: "décision-de-retrait"
    }

    raise "Unsupported attachment type" unless descriptions.keys.include?(attachment_name)

    name = attachment_file_name(descriptions[attachment_name])

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
