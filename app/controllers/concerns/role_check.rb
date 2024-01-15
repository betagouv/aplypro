# frozen_string_literal: true

module RoleCheck
  private

  def check_director(redirect_path: home_path)
    return if current_user.director?

    redirect_to redirect_path, status: :forbidden and return
  end

  def check_confirmed_director(alert_message: t("roles.errors.not_director"), redirect_path: home_path)
    return if current_user.confirmed_director?

    redirect_to redirect_path, alert: alert_message and return
  end

  def update_confirmed_director!
    if params[:confirmed_director] == "1"
      @etab.update(confirmed_director: current_user)
    elsif @etab.confirmed_director == current_user
      @etab.update(confirmed_director: nil)
    end
  end
end
