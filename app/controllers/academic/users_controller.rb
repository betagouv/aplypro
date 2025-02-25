# frozen_string_literal: true

module Academic
  class UsersController < ApplicationController
    skip_before_action :check_selected_academy

    before_action :infer_page_title

    def select_academy
      @academies = current_user.establishments
                               .select(:academy_code, :academy_label)
                               .distinct
                               .map { |e| ["#{e.academy_code} - #{e.academy_label}", e.academy_code] }
    end

    def selected_academy
      session[:selected_academy] = params[:academy]
      redirect_to academic_home_path
    end
  end
end
