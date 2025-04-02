# frozen_string_literal: true

module ASP
  class SchoolingsController < ApplicationController
    layout "application"

    before_action :set_schooling, :set_pfmps, only: :show
    before_action :set_search_result, :infer_page_title, only: :index

    def index; end

    def show
      infer_page_title(attributive_decision_number: @schooling.attributive_decision_number)
    end

    private

    def set_schooling
      @schooling = Schooling.find(params[:id])
    end

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
        .where("filename LIKE ?", "%#{@attributive_decision_number.strip.upcase}%")
    end
  end
end
