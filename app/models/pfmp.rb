# frozen_string_literal: true

class Pfmp < ApplicationRecord
  belongs_to :schooling

  has_one :classe, through: :schooling
  has_one :student, through: :schooling

  has_one :mef, through: :classe
  has_one :establishment, through: :classe

  has_many :transitions, class_name: "PfmpTransition", autosave: false, dependent: :destroy
  has_many :payments, -> { order("payments.created_at" => :asc) }, dependent: :destroy, inverse_of: :pfmp

  validates :start_date, :end_date, presence: true

  validates :end_date,
            comparison: { greater_than_or_equal_to: :start_date },
            if: -> { start_date && end_date }

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
    if day_count.present?
      transition_to!(:completed) if in_state?(:pending)
    elsif in_state?(:completed, :validated)
      transition_to!(:pending)
    end
  end

  def validate!
    transition_to!(:validated)
  end

  def setup_payment!
    amount = calculate_amount

    payments.create!(amount: amount) if amount.positive?
  end

  def calculate_amount
    return if day_count.nil?

    [
      day_count * wage.daily_rate,
      student.allowance_left(mef)
    ].min
  end

  # FIXME: use has_one instead
  def latest_payment
    payments.last
  end

  def relative_index
    schooling.pfmps.pluck(:id).find_index(id)
  end

  def relative_human_index
    relative_index + 1
  end
end
