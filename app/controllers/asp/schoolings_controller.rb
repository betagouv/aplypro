# frozen_string_literal: true

module ASP
  class SchoolingsController < ApplicationController
    layout "application"

    before_action :set_pfmps, only: :show
    before_action :set_search_result, :infer_page_title, only: :index

    def index; end

    def show; end

    private

    def set_pfmps
      return if @schooling.nil?

      @pfmps = @schooling
               .pfmps
               .joins(payment_requests: :asp_request)
               .distinct
    end

    def set_search_result
      @attributive_decision_number = params[:search]

      return if @attributive_decision_number.blank?

      @schoolings = find_schooling_by_attributive_decision_filename || []
    end

    def find_schooling_by_attributive_decision_filename
      Schooling
        .joins(:attributive_decision_blob)
        .find_by("filename LIKE ?", "%_#{@attributive_decision_number.strip.upcase}.pdf")
    end
  end
end
