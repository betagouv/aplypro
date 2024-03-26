# frozen_string_literal: true

module ASP
  class SchoolingsController < ApplicationController
    layout "application"

    before_action :sanitize_search, only: :search
    before_action :set_schooling, :set_pfmps, only: :show

    def search
      @page_title = "Rechercher un dossier"

      return if @search.blank?

      if (@schooling = find_schooling)
        redirect_to asp_schooling_path(@schooling)
      else
        redirect_to search_asp_schoolings_path, notice: t(".no_results", search: @search)
      end
    end

    def show
      @page_title = "Dossier #{@schooling.asp_dossier_id}"

      add_breadcrumb "Recherche d'un dossier", search_asp_schoolings_path
      add_breadcrumb @page_title
    end

    private

    def find_schooling
      @schooling =
        find_schooling_by_prestation_dossier_id ||
        find_schooling_by_asp_dossier_id ||
        find_schooling_by_attributive_decision_filename
    end

    def set_schooling
      @schooling = Schooling.find(params[:id])
    end

    def set_pfmps
      @pfmps = @schooling
               .pfmps
               .joins(payment_requests: :asp_request)
               .distinct
    end

    def find_schooling_by_prestation_dossier_id
      Schooling
        .joins(:pfmps)
        .find_by("pfmps.asp_prestation_dossier_id": @search)
    end

    def find_schooling_by_asp_dossier_id
      Schooling
        .find_by(asp_dossier_id: @search)
    end

    def find_schooling_by_attributive_decision_filename
      Schooling
        .joins(:attributive_decision_blob)
        .find_by("filename LIKE ?", "%#{@search}%")
    end

    def sanitize_search
      return if params[:search].blank?

      @search = params[:search].strip.upcase
    end
  end
end
