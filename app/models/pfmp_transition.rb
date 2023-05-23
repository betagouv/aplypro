# frozen_string_literal: true

class PfmpTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :pfmp, inverse_of: :pfmp_transitions

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = pfmp.pfmp_transitions.order(:sort_key).last
    return unless last_transition.present?

    last_transition.update_column(:most_recent, true)
  end
end
