# frozen_string_literal: true

module RoleCheck
  private

  def check_director(redirect_path: school_year_home_path(selected_school_year.start_year))
    return if current_user.director?

    redirect_to redirect_path, status: :forbidden and return
  end

  def check_confirmed_director(
    alert_message: t("roles.errors.not_director"),
    redirect_path: school_year_home_path(selected_school_year.start_year)
  )
    return if current_user.confirmed_director?

    redirect_back fallback_location: redirect_path, alert: alert_message and return
  end

  def update_confirmed_director!
    if params[:confirmed_director] == "1"
      current_establishment.update(confirmed_director: current_user)
    elsif current_establishment.confirmed_director == current_user
      current_establishment.update(confirmed_director: nil)
    end
  end
end
