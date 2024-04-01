# frozen_string_literal: true

class Pfmp < ApplicationRecord
  include PfmpAmountCalculator

  belongs_to :schooling
  has_one :classe, through: :schooling
  has_one :student, through: :schooling

  has_one :mef, through: :classe
  has_one :establishment, through: :classe

  has_many :transitions, class_name: "PfmpTransition", autosave: false, dependent: :destroy

  has_many :payment_requests, class_name: "ASP::PaymentRequest", dependent: :destroy

  validates :start_date, :end_date, presence: true

  validates :end_date,
            comparison: { greater_than_or_equal_to: :start_date },
            if: -> { start_date && end_date }

  validates :end_date, :start_date, inclusion: Aplypro::SCHOOL_YEAR_RANGE

  validates :day_count, numericality: { only_integer: true, allow_nil: true, greater_than: 0 }

  scope :finished, -> { where("pfmps.end_date <= (?)", Time.zone.today) }

  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: PfmpTransition,
    initial_state: PfmpStateMachine.initial_state,
  ]

  delegate :can_transition_to?,
           :current_state, :history, :last_transition, :last_transition_to,
           :transition_to!, :transition_to, :in_state?, to: :state_machine

  delegate :wage, to: :mef

  def state_machine
    @state_machine ||= PfmpStateMachine.new(
      self,
      transition_class: PfmpTransition,
      association_name: :transitions
    )
  end

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

    update_amounts!
  end

  def update_amounts!
    raise "A PFMP paid or in the process of being paid cannot have its amount recalculated" unless can_be_modified?

    update!(amount: calculate_amount)
    following_modifiable_pfmps_for_mef.first&.update_amounts!
  end

  def validate!
    transition_to!(:validated)
  end

  def setup_payment!
    payment_requests.create! if amount.positive?
  end

  def relative_index
    schooling.pfmps.pluck(:id).find_index(id)
  end

  def relative_human_index
    relative_index + 1
  end

  def administrative_number
    index = relative_human_index.to_s.rjust(2, "0")

    schooling.attributive_decision_number + index
  end

  def locked?
    payment_requests.ongoing.any? || paid?
  end

  def paid?
    payment_requests.in_state(:paid).any?
  end

  def can_be_modified?
    !locked?
  end

  def can_be_validated?
    student
      .pfmps
      .where("pfmps.created_at < (?)", created_at)
      .joins(schooling: :classe)
      .where("classe.mef_id": mef.id, "classe.start_year": Aplypro::SCHOOL_YEAR).not_in_state(:validated).empty?
  end

  def payment_due?
    day_count.present?
  end
end
