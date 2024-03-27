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

  after_save :handle_amount_change

  def handle_amount_change
    changed_day_count = day_count_before_last_save != day_count

    return if !changed_day_count

    raise "A PFMP paid or in the process of being paid cannot have its day count changed." unless can_be_modified?

    update_amount!
  end

  def validate!
    transition_to!(:validated)
  end

  def update_amount!
    update!(amount: calculate_amount)
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

  def can_be_modified?
    if in_state?(:validated)
      payment_requests.all?(&:stopped?)
    else
      true
    end
  end

  def can_be_validated?
    student.pfmps.where.not(id: id).where("pfmps.created_at < (?)", created_at).all? do |pfmp|
      pfmp.in_state?(:validated)
    end
  end

  def payment_due?
    day_count.present?
  end
end
