# frozen_string_literal: true

class PaymentStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :blocked
  state :ready
  state :processing
  state :successful
  state :failed

  transition from: :pending, to: :ready
  transition from: :pending, to: :blocked
  transition from: :blocked, to: :ready
  transition from: :ready, to: :processing
  transition from: :processing, to: :successful
  transition from: :processing, to: :failed

  guard_transition(to: :ready) do |payment|
    ASP::StudentFileEligibilityChecker.new(payment.student).ready?
  end
end
