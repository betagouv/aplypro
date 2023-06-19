# frozen_string_literal: true

class PfmpTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :pfmp

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = pfmp.pfmp_transitions.order(:sort_key).last
    return if last_transition.blank?

    last_transition.update_column(:most_recent, true)
  end

  def to_s
    t("pfmps.statuses.#{current_state}")
  end
end
