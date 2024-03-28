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

  guard_transition(to: :validated) do |pfmp| # rubocop:disable Style/SymbolProc
    pfmp.can_be_validated?
  end

  after_transition(to: :completed) do |pfmp| # rubocop:disable Style/SymbolProc
    pfmp.update_amount!
  end

  after_transition(to: :validated) do |pfmp| # rubocop:disable Style/SymbolProc
    pfmp.setup_payment!
  end
end
