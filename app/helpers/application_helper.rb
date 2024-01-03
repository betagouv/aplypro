# frozen_string_literal: true

module ApplicationHelper
  def success_badge(status, content)
    dsfr_badge(status: status, classes: ["fr-badge--sm fr-mb-0"]) do
      content
    end
  end
end
