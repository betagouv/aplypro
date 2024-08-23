# frozen_string_literal: true

class Pfmp < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include PfmpAmountCalculator

  TRANSITION_CLASS = PfmpTransition
  STATE_MACHINE_CLASS = PfmpStateMachine
  TRANSITION_RELATION_NAME = :transitions

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

  validates :end_date,
            :start_date,
            if: ->(pfmp) { pfmp.schooling.present? && pfmp.schooling.extended_end_date.nil?},
            inclusion: { in: ->(pfmp) { pfmp.schooling.establishment.school_year_range(pfmp.school_year.start_year) } }

  validates :end_date,
            comparison: { greater_than_or_equal_to: :start_date },
            if: -> { start_date && end_date }

  validates :day_count,
            numericality: {
              only_integer: true,
              allow_nil: true,
              greater_than: 0,
              less_than_or_equal_to: ->(pfmp) { (pfmp.end_date - pfmp.start_date).to_i + 1 }
            }

  after_create -> { self.administrative_number = administrative_number }

  scope :finished, -> { where("pfmps.end_date <= (?)", Time.zone.today) }
  scope :before, ->(date) { where("pfmps.created_at < (?)", date) }
  scope :after, ->(date) { where("pfmps.created_at > (?)", date) }

  delegate :wage, to: :mef

  before_destroy :ensure_destroyable?, prepend: true

  after_save do
    if day_count.present?
      transition_to!(:completed) if in_state?(:pending)
    elsif in_state?(:completed, :validated)
      transition_to!(:pending)
    end
  end

  after_save :recalculate_amounts_if_needed

  # Recalculate amounts for the current PFMP and all follow up PFMPs that are still modifiable
  def recalculate_amounts_if_needed
    changed_day_count = day_count_before_last_save != day_count

    return if !changed_day_count

    PfmpManager.new(self).recalculate_amounts!
  end

  def validate!
    transition_to!(:validated)
  end

  def rectify!
    transition_to!(:rectified)
  end

  def relative_index
    schooling.pfmps.order(created_at: :asc).pluck(:id).find_index(id)
  end

  def relative_human_index
    relative_index + 1
  end

  def administrative_number
    index = relative_human_index.to_s.rjust(2, "0")

    schooling.attributive_decision_number + index
  end

  def locked?
    latest_payment_request&.ongoing?
  end

  def within_schooling_dates?
    return true if (schooling.open? && start_date >= schooling.start_date) || schooling.no_dates?

    (schooling.start_date..schooling.max_end_date).cover?(start_date..end_date)
  end

  def paid?
    payment_requests.in_state(:paid).any?
  end

  def can_be_modified?
    !locked?
  end

  def can_be_destroyed?
    return true if latest_payment_request.blank?

    latest_payment_request.in_state?(:pending, :incomplete)
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
end
