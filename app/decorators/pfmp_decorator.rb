# frozen_string_literal: true

module PfmpDecorator
  def status_badge
    dsfr_badge(status: state_machine.state_to_badge) do
      t("pfmps.states.#{current_state}")
    end
  end
end
