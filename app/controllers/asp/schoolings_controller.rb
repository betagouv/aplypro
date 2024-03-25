# frozen_string_literal: true

module ASP
  class SchoolingsController < ApplicationController
    layout "application"

    before_action :sanitize_search, :set_schooling_result

    def index
      @inhibit_nav = true
      @page_title = "Rechercher un dossier"

      return if @schooling.blank?

      @inhibit_title = true
      @page_title = "Dossier #{@schooling.asp_dossier_id}"
      @pfmps = @schooling
               .pfmps
               .joins(payment_requests: :asp_request)
               .distinct
    end

    private

    def set_schooling_result
      @schooling = Schooling.joins(:pfmps).find_by("pfmps.asp_prestation_dossier_id": @search)
      return if @schooling.present?

      @schooling = Schooling.find_by(asp_dossier_id: @search)
      return if @schooling.present?

      @schooling = Schooling
                   .joins(:attributive_decision_blob)
                   .find_by("filename LIKE ?", "%#{@search}%")
    end

    def sanitize_search
      return if params[:search].blank?

      @search = params[:search].strip.upcase
    end
  end
end
