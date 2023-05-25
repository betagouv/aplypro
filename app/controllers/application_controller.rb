# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def after_sign_in_path_for(_resource)
    classes_path
  end

  protected

  def infer_page_title(attrs = {})
    key = page_title_key

    return unless I18n.exists?(key)

    @page_title = I18n.t(key, **attrs)

    add_breadcrumb @page_title
  end

  def page_title_key
    ["pages", "titles", controller_name, action_name].join(".")
  end
end
