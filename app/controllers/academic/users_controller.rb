# frozen_string_literal: true

module Academic
  class UsersController < Academic::ApplicationController
    skip_before_action :check_selected_academy, only: :select_academy

    helper_method :academies

    def select_academy
      @inhibit_banner = true
    end

    def index
      @users = User.joins(:directed_establishments)
                   .where(establishments: { academy_code: selected_academy })
                   .includes(:directed_establishments)
                   .distinct
                   .page(params[:page])
                   .per(50)
    end
  end
end
