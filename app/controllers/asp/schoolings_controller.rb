# frozen_string_literal: true

module ASP
  class SchoolingsController < ApplicationController
    layout "application"

    before_action :sanitize_search,
                  :set_schooling_result,
                  :set_pfmps

    def index
      @page_title = "Rechercher un dossier"

      return if @schooling.nil?

      @inhibit_title = true

      @page_title = "Dossier #{@schooling.asp_dossier_id}"
    end

    private

    def set_schooling_result
      return if @search.blank?

      @schooling = find_schooling_by_attributive_decision_filename
    end

    def set_pfmps
      return if @schooling.nil?

      @pfmps = @schooling
               .pfmps
               .joins(payment_requests: :asp_request)
               .distinct
    end

    def find_schooling_by_attributive_decision_filename
      Schooling
        .joins(:attributive_decision_blob)
        .find_by("filename LIKE ?", "%_#{@search}.pdf")
    end

    def sanitize_search
      return if params[:search].blank?

      @search = params[:search].strip.upcase
    end
  end
end
