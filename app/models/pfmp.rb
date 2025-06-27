# frozen_string_literal: true

class Pfmp < ApplicationRecord # rubocop:disable Metrics/ClassLength
  TRANSITION_CLASS = PfmpTransition
  STATE_MACHINE_CLASS = PfmpStateMachine
  TRANSITION_RELATION_NAME = :transitions
  attr_accessor :skip_amounts_yearly_cap_validation

  include ::StateMachinable

  has_many :transitions, class_name: "PfmpTransition", autosave: false, dependent: :destroy

  belongs_to :schooling

  has_one :classe, through: :schooling
  has_one :school_year, through: :classe
  has_one :student, through: :schooling
  has_one :mef, through: :classe
  has_one :establishment, through: :classe

  has_many :payment_requests,
           class_name: "ASP::PaymentRequest",
           inverse_of: :pfmp,
           dependent: :destroy

  has_one :latest_payment_request,
          -> { order "asp_payment_requests.created_at" => :desc },
          class_name: "ASP::PaymentRequest",
          inverse_of: :pfmp,
          dependent: :destroy

  validates :start_date, :end_date, presence: true

  validate :amounts_yearly_cap
  validate :rectified_amount_must_differ_from_paid_amount, if: :rectified?

  validates :end_date,
            :start_date,
            if: ->(pfmp) { pfmp.schooling.present? },
            inclusion: {
              in: lambda { |pfmp|
                pfmp.schooling.establishment.school_year_range(
                  pfmp.school_year.start_year,
                  pfmp.schooling.extended_end_date
                )
              }
            }

  validates :end_date,
            comparison: { greater_than_or_equal_to: :start_date },
            if: -> { start_date && end_date }

  validates :amount, numericality: { only_integer: true, allow_nil: true, greater_than_or_equal_to: 0 }

  validates :day_count,
            numericality: {
              only_integer: true,
              allow_nil: true,
              greater_than: 0,
              less_than_or_equal_to: ->(pfmp) { pfmp.calculate_max_day_count }
            }, if: :should_validate_day_count?

  after_create -> { self.administrative_number = administrative_number }

  scope :finished, -> { where("pfmps.end_date <= (?)", Time.zone.today) }

  scope :for_year, lambda { |start_year|
                     joins(schooling: { classe: :school_year })
                       .where(school_year: { start_year: start_year })
                   }

  delegate :wage, to: :mef

  before_destroy :ensure_destroyable?, prepend: true

  def validate!
    return if in_state?(:validated)

    transition_to!(:validated)
  end

  def rectify!
    transition_to!(:rectified)
  end

  def rectified?
    in_state?(:rectified)
  end

  def relative_index
    schooling.pfmps.order(created_at: :asc).pluck(:id).find_index(id)
  end

  def relative_human_index
    relative_index + 1
  end

  def administrative_number
    numadm = attributes["administrative_number"]
    return numadm if numadm.present?

    index = relative_human_index.to_s.rjust(2, "0")

    schooling.attributive_decision_number + index
  end

  def num_presta_doss
    return nil if latest_payment_request.nil? || latest_payment_request.last_transition_to(:integrated).nil?

    latest_payment_request.last_transition_to(:integrated).metadata["numAdmPrestaDoss"]
  end

  def within_schooling_dates?
    return true if (schooling.open? && start_date >= schooling.start_date) || schooling.no_dates?

    (schooling.start_date..schooling.max_end_date).cover?(start_date..end_date)
  end

  def paid?
    payment_requests.in_state(:paid).any?
  end

  def payable?
    amount.positive? || (rectified? && amount.zero?)
  end

  def can_be_modified?
    !latest_payment_request&.ongoing?
  end

  def can_be_rebalanced?
    !latest_payment_request&.ongoing? && !latest_payment_request&.in_state?(:paid)
  end

  def can_be_destroyed?
    asp_prestation_dossier_id.blank? && payment_requests.none?(&:ongoing?)
  end

  def stalled_payment_request?
    latest_payment_request&.failed?
  end

  def payment_due?
    day_count.present?
  end

  def overlaps
    student.pfmps.excluding(self).select do |other|
      (other.start_date..other.end_date).overlap?(start_date..end_date)
    end
  end

  def ensure_destroyable?
    return true if can_be_destroyed?

    errors.add(:base, :locked)
    throw :abort
  end

  def can_retrigger_payment?
    latest_payment_request.failed?
  end

  def all_pfmps_for_mef
    student.pfmps
           .joins(schooling: :classe)
           .where("classes.mef_id": mef.id, "classes.school_year_id": school_year.id)
  end

  def check_validation_transition
    errors.add(:rib, "Les coordonnées bancaires sont manquantes") if student.rib(establishment).blank?
    errors.add(:da, "La décision d'attribution est manquante") unless schooling.attributive_decision.attached?
    errors.add(:end_date, "La date de fin de la PFMP est supérieure à la date du jour") if end_date > DateTime.now
  end

  def calculate_max_day_count
    (end_date - start_date).to_i + 1
  end

  def paid_amount
    last_paid_request = payment_requests.in_state(:paid).order(created_at: :desc).first
    return unless last_paid_request

    last_paid_request
      .last_transition_to(:paid)
      .metadata
      .dig("PAIEMENT", "MTNET")
      .to_i
  end

  private

  # NOTE: a rectification with a 0 day count can be created to cancel a payment
  def should_validate_day_count?
    !rectified? && start_date.present? && end_date.present?
  end

  def amounts_yearly_cap
    return if skip_amounts_yearly_cap_validation
    return unless mef

    pfmps = all_pfmps_for_mef
    cap = mef.wage.yearly_cap
    total = pfmps.to_a.map { |pfmp| pfmp.amount || 0 }.sum
    return unless total > cap

    errors.add(:amount,
               "Yearly cap of #{cap} not respected for Mef code: #{mef.code} \\
               -> #{total}/#{cap} with #{pfmps.count} PFMPs")
  end

  def rectified_amount_must_differ_from_paid_amount
    return unless amount.present? && paid_amount.present?
    return if amount != paid_amount

    errors.add(:amount, "must be different from the previously paid amount (#{paid_amount}€) when rectifying")
  end
end
