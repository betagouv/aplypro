# frozen_string_literal: true

module Academic
  class UsersController < ApplicationController
    skip_before_action :check_selected_academy

    before_action :infer_page_title

    def select_academy
      @academies = session[:academy_codes]
    end

    def selected_academy
      session[:selected_academy] = params[:academy]
      redirect_to academic_home_path
    end
  end
end
