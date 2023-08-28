# frozen_string_literal: true

class Pfmp < ApplicationRecord
  belongs_to :schooling

  has_one :classe, through: :schooling
  has_one :student, through: :schooling

  has_one :mef, through: :classe
  has_one :establishment, through: :classe

  has_many :transitions, class_name: "PfmpTransition", autosave: false, dependent: :destroy
  has_many :payments, -> { order(updated_at: :asc) }, dependent: :destroy, inverse_of: :pfmp

  validates :start_date, :end_date, presence: true
  validates :day_count, numericality: { only_integer: true, allow_nil: true, greater_than: 0 }

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
    if in_state?(:pending) && day_count.present? # rubocop:disable Style/IfUnlessModifier
      transition_to!(:completed)
    end
  end

  def setup_payment!
    payments.create!(amount: calculate_amount) if payment_due?
  end

  def calculate_amount
    return if day_count.nil?

    [
      day_count * wage.daily_rate,
      student.allowance_left
    ].min
  end

  # FIXME: use has_one instead
  def latest_payment
    payments.last
  end

  def payable?
    student.rib.present?
  end

  def payment_due?
    student.allowance_left > 0 # rubocop:disable Style:NumericPredicate
  end

  def unscheduled?
    payments.none?
  end

  def breakdown
    I18n.t("pfmps.breakdown", days: day_count, rate: wage.daily_rate, total: calculate_amount)
  end

  def payment_state
    if payable?
      latest_payment.state_machine.current_state
    else
      :blocked
    end
  end
end
