# frozen_string_literal: true

module Academic
  class UsersController < ApplicationController
    skip_before_action :check_selected_academy

    before_action :infer_page_title

    helper_method :academies

    def select_academy
      @inhibit_banner = true
    end

    def selected_academy
      session[:selected_academy] = params[:academy]
      redirect_to academic_home_path
    end

    def index
    end
  end
end
