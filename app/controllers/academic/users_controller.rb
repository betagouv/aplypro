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
      session[:selected_academy] = params[:academy]
      redirect_to academic_home_path
    end

    def index
      @users = User.joins(establishment_user_roles: :establishment)
                   .where(establishment_user_roles: { role: :dir })
                   .where(establishments: { academy_code: selected_academy })
                   .includes(:establishments, :directed_establishments)
                   .distinct
                   .page(params[:page])
                   .per(50)
    end
  end
end
