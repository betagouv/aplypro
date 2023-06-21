# frozen_string_literal: true

class PaymentStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :processing
  state :success
  state :failure

  transition from: :pending, to: :processing
  transition from: :processing, to: :success
end
