# frozen_string_literal: true

class SchoolYearsController < ApplicationController
  def select
    infer_page_title
  end

  def selected
    start_year = params[:school_year_id]

    session[:start_year] = start_year

    redirect_to school_year_home_path(start_year)
  end
end
