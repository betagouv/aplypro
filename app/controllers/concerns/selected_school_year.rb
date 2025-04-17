# frozen_string_literal: true

module SelectedSchoolYear
  extend ActiveSupport::Concern

  def selected_school_year
    @selected_school_year =
      SchoolYear.find_by(start_year: params[:school_year_id]) ||
      SchoolYear.find_by(start_year: session[:start_year]) ||
      SchoolYear.current
  end
end
