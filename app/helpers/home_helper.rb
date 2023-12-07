# frozen_string_literal: true

module HomeHelper
  def indicator_badge(count, total)
    status = indicator_badge_status(count, total)

    dsfr_badge(status: status, classes: ["fr-badge counter"]) do
      "#{count} / #{total}"
    end
  end

  def attributive_decisions_download_button(establishment, klass: "")
    count = establishment.current_schoolings.with_attributive_decisions.count

    return if count.zero?

    button_to(
      t("panels.attributive_decisions.download", count: count),
      establishment_download_attributive_decisions_path(establishment),
      method: :post,
      class: "fr-btn fr-btn--primary #{klass}",
      data: { turbo: false }
    )
  end

  def attributive_decisions_generation_button(establishment, klass: "")
    return cannot_generate_attributive_decisions_button unless current_user.can_generate_attributive_decisions?

    count = establishment.current_schoolings.without_attributive_decisions.count

    button_to(
      t("panels.attributive_decisions.generate", count: count),
      establishment_create_attributive_decisions_path(establishment),
      class: "fr-btn fr-btn--secondary #{klass}",
      data: { turbo: false }
    )
  end

  def cannot_generate_attributive_decisions_button(klass: "")
    button_to(
      t("panels.attributive_decisions.not_allowed"),
      "#",
      class: "fr-btn fr-btn--primary #{klass}",
      disabled: true
    )
  end

  def indicator_badge_status(count, total)
    if total.zero?
      :error
    else
      case count / total
      when 0..0.5
        :error
      when 0.51..0.99
        :warning
      when 1
        :success
      end
    end
  end

  def status_badge(status)
    status_level = PfmpDecorator::PFMP_STATE_MAPPING[status]
    dsfr_badge(status: status_level, classes: ["fr-badge"]) do
      t("pfmps.states.#{status}")
    end
  end

  def pfmp_badge(state, pfmps_counts)
    count_tag = content_tag(:div, class: "fr-mr-1w") do
      pfmps_counts[state.to_s].to_s
    end

    count_tag.concat(status_badge(state))
  end

  def school_year_to_s
    starting_year = ENV.fetch("APLYPRO_SCHOOL_YEAR").to_i

    t("year", start_year: starting_year, end_year: starting_year + 1)
  end
end
