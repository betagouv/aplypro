# frozen_string_literal: true

class PfmpStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :completed
  state :validated
  state :rectified

  transition from: :pending, to: :completed
  transition from: :completed, to: :validated
  transition from: :completed, to: :pending
  transition from: :validated, to: :rectified
  transition from: :rectified, to: :rectified

  guard_transition(to: :completed) do |pfmp|
    pfmp.day_count.present?
  end

  guard_transition(to: :validated) do |pfmp|
    pfmp.check_validation_transition

    pfmp.errors.none?
  end

  guard_transition(to: :rectified) do |pfmp|
    pfmp.latest_payment_request&.in_state?(:paid)
  end

  after_transition(to: :rectified) do |pfmp|
    new_payment_request = PfmpManager.new(pfmp).create_new_payment_request!
    new_payment_request.mark_ready!
    Sync::StudentJob.perform_later(pfmp.schooling)
  end

  after_transition(to: :validated) do |pfmp|
    PfmpManager.new(pfmp).create_new_payment_request!
    Sync::StudentJob.perform_later(pfmp.schooling)
  end
end
