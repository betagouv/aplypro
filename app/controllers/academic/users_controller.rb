# frozen_string_literal: true

module Academic
  class UsersController < Academic::ApplicationController
    skip_before_action :check_selected_academy, only: :select_academy

    helper_method :academies

    VALID_SORT_OPTIONS = %w[name email uai last_sign_in].freeze
    USERS_PER_PAGE = 50

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
                   .then { |relation| apply_sorting(relation) }
                   .preload(
                     establishment_user_roles: {
                       establishment: :confirmed_director
                     }
                   )
                   .page(params[:page])
                   .per(USERS_PER_PAGE)
    end

    private

    def filter_by_role(relation)
      return relation if params[:role].blank?
      return relation unless EstablishmentUserRole.roles.key?(params[:role])

      relation.where(establishment_user_roles: { role: params[:role] })
    end

    def apply_sorting(relation)
      case sort_column
      when "uai"
        relation.select("users.*, MIN(establishments.name) as min_establishment_name")
                .group("users.id")
                .order("min_establishment_name ASC, users.name ASC")
      when "email"
        relation.distinct.order("users.email ASC")
      when "last_sign_in"
        relation.distinct.order(Arel.sql("users.last_sign_in_at DESC NULLS LAST"))
      else
        relation.distinct.order("users.name ASC")
      end
    end

    def sort_column
      VALID_SORT_OPTIONS.include?(params[:sort]) ? params[:sort] : "name"
    end
  end
end
