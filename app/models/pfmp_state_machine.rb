# frozen_string_literal: true

class PfmpStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :completed
  state :validated

  transition from: :pending, to: :completed
  transition from: :completed, to: :validated
  transition from: :completed, to: :pending

  guard_transition(to: :completed) do |pfmp|
    pfmp.day_count.present?
  end

  guard_transition(to: :validated) do |pfmp|
    pfmp.previous_pfmps.not_in_state(:validated).empty?
  end

  after_transition(to: :completed) do |pfmp|
    PfmpManager.new(pfmp).recalculate_amounts!
  end

  after_transition(to: :validated) do |pfmp|
    PfmpManager.new(pfmp).reset_payment_request!
  end
end
