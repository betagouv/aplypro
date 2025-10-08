# frozen_string_literal: true

module Academic
  class ReportsController < Academic::ApplicationController
    def index
      infer_page_title
      @inhibit_banner = true
      @reports = Report.includes(:school_year).order(created_at: :desc)
    end
  end
end
