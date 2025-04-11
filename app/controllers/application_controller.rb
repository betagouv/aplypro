# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include UserLogger
  include PageTitle
  include SelectedSchoolYear

  before_action :authenticate_user!,
                :log_user,
                :redirect_asp_users!,
                :redirect_academic_users!,
                :check_maintenance,
                :check_current_establishment

  helper_method :current_establishment, :selected_school_year

  def after_sign_in_path_for(_resource)
    school_year_classes_path(selected_school_year)
  end

  protected

  def after_sign_out_path_for(resource_or_scope)
    case resource_or_scope
    when :user
      new_user_session_path
    when :asp_user
      new_asp_user_session_path
    when :academic_user
      new_academic_user_session_path
    end
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

  def redirect_asp_users!
    redirect_to asp_schoolings_path and return if asp_user_signed_in?
  end

  def redirect_academic_users!
    redirect_to academic_home_path and return if academic_user_signed_in?
  end

  private

  def check_current_establishment
    return unless user_signed_in?

    redirect_to user_select_establishment_path(current_user) if current_establishment.nil?
  end
end
