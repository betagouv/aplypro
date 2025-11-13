# frozen_string_literal: true

module Academic
  module ApplicationHelper
    def sortable_column_header(column:, label:, path:, current_sort:, **options)
      is_active = (current_sort.blank? && column == "name") || current_sort == column
      css_class = ["fr-link", ("fr-text--heavy" if is_active)].compact.join(" ")
      title = "Trier par #{label.downcase}"

      link_to path, class: css_class, title: title, **options do
        concat label
        concat " "
        concat content_tag(:i, "", class: "fr-icon-arrow-down-s-line fr-icon--sm") if is_active
      end
    end

    def sortable_table_hint
      content_tag(:p, class: "fr-text--sm fr-text--mention-grey fr-mb-1w") do
        concat content_tag(:i, "", class: "fr-icon-arrow-up-down-line fr-icon--sm")
        concat " "
        concat "Cliquez sur les en-têtes de colonne pour trier"
      end
    end
  end
end
