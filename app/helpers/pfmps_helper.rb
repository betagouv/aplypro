# frozen_string_literal: true

module PfmpsHelper
  def pfmp_state_tab_title(state, group)
    label = t("pfmps.states.#{state}")
    count = group.size

    "#{label} (#{count})"
  end
end
