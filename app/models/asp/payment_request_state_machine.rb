# frozen_string_literal: true

module ASP
  class PaymentRequestStateMachine
    include Statesman::Machine

    state :pending, initial: true
    state :sent
    state :rejected

    transition from: :pending, to: :sent
    transition from: :sent, to: :rejected
  end
end
