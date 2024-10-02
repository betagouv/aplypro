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
    pfmp.previous_pfmps.not_in_state(:validated).empty? &&
      pfmp.student.rib(pfmp.classe.establishment).present? &&
      pfmp.schooling.attributive_decision.attached?
  end

  guard_transition(to: :rectified) do |pfmp|
    pfmp.latest_payment_request.in_state?(:paid)
  end

  after_transition(to: :rectified) do |pfmp|
    PfmpManager.new(pfmp).recalculate_amounts!
    new_payment_request = PfmpManager.new(pfmp).create_new_payment_request!
    new_payment_request.mark_ready!
  end

  after_transition(to: :completed) do |pfmp|
    PfmpManager.new(pfmp).recalculate_amounts!
  end

  after_transition(to: :validated) do |pfmp|
    PfmpManager.new(pfmp).create_new_payment_request!
  end
end
