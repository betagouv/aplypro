# frozen_string_literal: true

module Academic
  class SchoolYearsController < ApplicationController
    def select; end

    def selected
      start_year = params[:school_year_id]

      session[:start_year] = start_year

      redirect_to academic_home_path
    end
  end
end
