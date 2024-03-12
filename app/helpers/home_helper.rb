# frozen_string_literal: true

module HomeHelper
  def progress_badge(count, total, **args)
    count ||= 0
    status = progress_badge_status(count, total)

    content_tag(:div, title: args[:title]) do
      dsfr_badge(status: status, classes: ["fr-badge counter"]) do
        "#{count} / #{total}"
      end
    end
  end

  def attributive_decisions_download_button(establishment)
    count = establishment.schoolings.with_attributive_decisions.count

    return if count.zero?

    button_to(
      t("panels.attributive_decisions.download", count: count),
      establishment_download_attributive_decisions_path(establishment),
      method: :post,
      class: "fr-btn fr-btn--primary",
      data: { turbo: false }
    )
  end

  def attributive_decisions_generation_form(establishment)
    return cannot_generate_attributive_decisions_button unless current_user.can_try_to_generate_attributive_decisions?

    count = establishment.schoolings.without_attributive_decisions.count

    render partial: "home/attributive_decision_form", locals: { establishment: establishment, count: count }
  end

  def cannot_generate_attributive_decisions_button
    button_to(
      t("panels.attributive_decisions.not_allowed"),
      "#",
      class: "fr-btn fr-btn--primary",
      disabled: true
    )
  end

  def progress_badge_status(count, total)
    if total.nil? || total.zero?
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

  def school_year_to_s
    starting_year = ENV.fetch("APLYPRO_SCHOOL_YEAR").to_i

    t("year", start_year: starting_year, end_year: starting_year + 1)
  end

  def confirmed_director_information
    return if current_user.selected_establishment.confirmed_director.blank? || current_user.confirmed_director?

    I18n.t(
      "panels.attributive_decisions.confirm_director_information",
      name: current_user.selected_establishment.confirmed_director.name
    )
  end
end
