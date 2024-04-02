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
    pfmp.student
        .pfmps
        .before(pfmp.created_at)
        .joins(schooling: :classe)
        .where("classe.mef_id": pfmp.mef.id, "classe.start_year": Aplypro::SCHOOL_YEAR).not_in_state(:validated).empty?
  end

  after_transition(to: :completed) do |pfmp| # rubocop:disable Style/SymbolProc
    pfmp.update_amounts!
  end

  after_transition(to: :validated) do |pfmp| # rubocop:disable Style/SymbolProc
    pfmp.setup_payment!
  end
end
