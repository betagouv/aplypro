# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ClassesIndicators

  before_action :authenticate_user!,
                :check_maintenance,
                :check_current_establishment,
                :set_support_banner

  helper_method :current_establishment

  def after_sign_in_path_for(_resource)
    classes_path
  end

  protected

  def set_support_banner
    @show_support_banner = eligible_for_support?(current_establishment)
  end

  def check_maintenance
    return if request.path == maintenance_path # or endless redirect

    redirect_to maintenance_path if maintenance_mode?
  end

  def maintenance_mode?
    ENV.fetch("APLYPRO_MAINTENANCE_REASON", nil).present?
  end

  def current_establishment
    @current_establishment ||= current_user&.selected_establishment
  end

  def infer_page_title(attrs = {})
    key = page_title_key

    return unless I18n.exists?(key)

    title, breadcrumb = extract_title_data(I18n.t(key, deep_interpolation: true, **attrs))

    @page_title = title

    add_breadcrumb(breadcrumb)
  end

  def extract_title_data(data)
    if data.is_a? Hash
      [data[:title], data[:breadcrumb]]
    else
      [data, data]
    end
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

  def check_current_establishment
    return unless user_signed_in?

    redirect_to user_select_establishment_path(current_user) if current_establishment.nil?
  end

  def fetch_classes_indicators(classes)
    @nb_students_per_class = nb_students_per_class(classes)
    @nb_attributive_decisions_per_class = nb_attributive_decisions_per_class(classes)
    @nb_ribs_per_class = nb_ribs_per_class(classes)
    @nb_pfmp_per_class_and_status = nb_pfmp_per_class_and_status(classes)
  end
end
