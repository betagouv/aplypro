# frozen_string_literal: true

module Academic
  class UsersController < Academic::ApplicationController
    include UserFiltering

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
      @search_query = normalize_search_query
      @users = filtered_academy_users
      @academy_eurs_by_user = load_academy_establishment_user_roles
    end

    private

    def filtered_academy_users
      User.joins(establishment_user_roles: :establishment)
          .where(establishments: { academy_code: selected_academy })
          .then { |relation| apply_search(relation) }
          .then { |relation| filter_by_role(relation) }
          .then { |relation| apply_user_sorting(relation, include_uai: true) }
          .page(params[:page])
          .per(users_per_page)
    end

    def load_academy_establishment_user_roles
      EstablishmentUserRole
        .joins(:establishment)
        .where(user_id: @users.reorder(nil).pluck(:id), establishments: { academy_code: selected_academy })
        .includes(establishment: :confirmed_director)
        .group_by(&:user_id)
    end
  end
end
