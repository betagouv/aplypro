# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :check_maintenance, :set_establishment, :set_support_banner

  def after_sign_in_path_for(_resource)
    classes_path
  end

  protected

  def set_support_banner
    @show_support_banner = eligible_for_support?(@etab)
  end

  def check_maintenance
    return if request.path == maintenance_path # or endless redirect

    redirect_to maintenance_path if maintenance_mode?
  end

  def maintenance_mode?
    ENV.fetch("APLYPRO_MAINTENANCE_REASON", nil).present?
  end

  def set_establishment
    @etab = current_user&.establishment
  end

  def infer_page_title(attrs = {})
    key = page_title_key

    return unless I18n.exists?(key)

    @page_title = I18n.t(key, **attrs)

    add_breadcrumb @page_title
  end

  def page_title_key
    ["pages", "titles", controller_name, action_name].join(".")
  end

  private

  def eligible_for_support?(establishment)
    return false if establishment.nil?

    supported_uais = ENV
                     .fetch("APLYPRO_DIRECT_SUPPORT_UAIS", "")
                     .split(",")

    supported_uais.include?(establishment.uai)
  end
end
