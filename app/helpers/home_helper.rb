# frozen_string_literal: true

module HomeHelper
  def attributive_decisions_download_button
    count = current_establishment.schoolings.with_attributive_decisions
                                 .joins(:classe)
                                 .where(classe: { school_year: selected_school_year })
                                 .count

    button_to(
      t("panels.attributive_decisions.download", count: count),
      school_year_establishment_download_attributive_decisions_path(selected_school_year, current_establishment),
      method: :post,
      class: "fr-btn fr-btn--primary",
      data: { turbo: false }
    )
  end

  def attributive_decisions_generation_form
    count = current_establishment.schoolings.without_attributive_decisions
                                 .joins(:classe)
                                 .where(classe: { school_year: selected_school_year })
                                 .count

    render partial: "home/attributive_decision_form", locals: { establishment: current_establishment, count: count }
  end

  def cannot_generate_attributive_decisions_button
    button_to(
      t("panels.attributive_decisions.not_allowed"),
      "#",
      class: "fr-btn fr-btn--primary",
      disabled: true
    )
  end

  def confirmed_director_information
    return if current_user.selected_establishment.confirmed_director.blank? || current_user.confirmed_director?

    I18n.t(
      "panels.attributive_decisions.confirm_director_information",
      name: current_user.selected_establishment.confirmed_director.name
    )
  end
end
