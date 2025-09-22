# frozen_string_literal: true

class AbrogationsController < ApplicationController
  def index
    infer_page_title

    @schoolings_per_school_year = current_establishment.schoolings
                                                       .select(&:any_older_schooling?)
                                                       .group_by(&:school_year)
  end
end
