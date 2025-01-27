# frozen_string_literal: true

module PageTitle
  extend ActiveSupport::Concern

  def infer_page_title(attrs = {})
    key = page_title_key

    return unless I18n.exists?(key)

    title, breadcrumb = extract_title_data(I18n.t(key, deep_interpolation: true, **attrs))

    @page_title = title

    add_breadcrumb(breadcrumb)
  end

  private

  def page_title_key
    asp = "asp" if controller_path.eql?("asp/application")
    ["pages", "titles", asp, controller_name, action_name].join(".")
  end

  def extract_title_data(data)
    if data.is_a? Hash
      [data[:title], data[:breadcrumb]]
    else
      [data, data]
    end
  end
end
