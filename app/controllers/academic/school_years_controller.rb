# frozen_string_literal: true

module Academic
  class SchoolYearsController < ApplicationController
    def select; end

    def selected
      start_year = params[:school_year_id]

      if SchoolYear.exists?(start_year: start_year)
        session[:start_year] = start_year
        redirect_to academic_home_path
      else
        redirect_to select_academic_school_years_path, alert: t(".invalid_school_year")
      end
    end
  end
end
