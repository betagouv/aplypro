# frozen_string_literal: true

class AbrogationsController < ApplicationController
  def index
    infer_page_title

    schoolings = []
    @schoolings_per_school_year = current_establishment.schoolings.each do |schooling|
      schoolings << schooling if schooling.open? && !schooling.abrogation_decision.attached?
    end
    @schoolings_per_school_year = schoolings.group_by(&:school_year)
  end
end
