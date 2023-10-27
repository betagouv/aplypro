# frozen_string_literal: true

module DsfrHelper
  class BreadcrumbBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
    def render
      # rubocop:disable Rails/HelperInstanceVariable
      @context.dsfr_breadcrumbs do |component|
        return "" if @elements.one?

        @elements.map do |element|
          component.breadcrumb(href: element.path, label: element.name)
        end
      end
      # rubocop:enable Rails/HelperInstanceVariable
    end
  end
end
