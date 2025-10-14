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

      relation.where(establishment_user_roles: { role: params[:role] })
    end
  end
end
