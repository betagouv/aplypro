# frozen_string_literal: true

class PfmpStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :validated

  transition from: :pending, to: :validated

  guard_transition(to: :validated) do |pfmp|
    pfmp.day_count.present?
  end

  after_transition(to: :validated) do |pfmp| # rubocop:disable Style/SymbolProc
    pfmp.setup_payment!
  end

  def state_to_badge
    :new
  end
end
