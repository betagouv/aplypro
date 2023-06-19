# frozen_string_literal: true

class Pfmp < ApplicationRecord
  belongs_to :student

  has_many :transitions, class_name: "PfmpTransition", autosave: false, dependent: :destroy
  has_many :payments, -> { order(updated_at: :asc) }, dependent: :destroy, inverse_of: :pfmp

  # FIXME: this is bound to disappear ; a PFMP doesn't really
  # transition into any states, but it might trigger one or more
  # payments and *they* will go through different states. Keeping the
  # plumbing in case we need it but will remove if not.
  #
  # Note to self: never write anticipatory code
  def state_machine
    @state_machine ||= PfmpStateMachine.new(
      self,
      transition_class: PfmpTransition,
      association_name: :transitions
    )
  end

  after_create do
    setup_payment! if payable?
  end

  def setup_payment!
    payments.create!(amount: calculate_amount)
  end

  def calculate_amount
    42 # we don't have the legal numbers yet
  end

  # FIXME: use has_one instead
  def latest_payment
    payments.last
  end

  def payable?
    student.rib.present?
  end

  def unscheduled?
    payments.none?
  end

  def payment_state
    if payable?
      latest_payment.state_machine.current_state
    else
      :blocked
    end
  end
end
