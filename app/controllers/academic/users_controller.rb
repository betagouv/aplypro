# frozen_string_literal: true

module Academic
  class UsersController < Academic::ApplicationController
    skip_before_action :check_selected_academy, only: :select_academy

    helper_method :academies

    def select_academy
      @inhibit_banner = true
      @inhibit_nav = true
    end

    def set_selected_academy
      academy_code = params[:academy]

      if authorised_academy_codes&.include?(academy_code)
        session[:selected_academy] = academy_code
        redirect_to academic_home_path
      else
        redirect_to select_academy_academic_users_path(current_user), alert: t(".unauthorized_academy")
      end
    end

    def index
      @users = User.joins(establishment_user_roles: :establishment)
                   .where(establishments: { academy_code: selected_academy })
                   .then { |relation| filter_by_role(relation) }
                   .includes(:establishments, :directed_establishments, :establishment_user_roles)
                   .distinct
                   .page(params[:page])
                   .per(50)
    end

    private

    def filter_by_role(relation)
      return relation if params[:role].blank?

      allowed_roles = EstablishmentUserRole.roles.keys
      return relation unless allowed_roles.include?(params[:role])

      relation.where(establishment_user_roles: { role: params[:role] })
    end
  end
end
