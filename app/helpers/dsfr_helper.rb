# frozen_string_literal: true

module DsfrHelper
  class BreadcrumbBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
    def render
      @context.dsfr_breadcrumbs do |component|
        return "" if @elements.one?

        @elements.map do |element|
          component.with_breadcrumb(href: element.path, label: element.name)
        end
      end
    end
  end
end
