# frozen_string_literal: true

class PaymentStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :ready
  state :processing
  state :successful
  state :failed

  transition from: :pending, to: :ready
  transition from: :ready, to: :processing
  transition from: :processing, to: :successful
  transition from: :processing, to: :failed
end
