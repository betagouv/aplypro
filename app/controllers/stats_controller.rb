# frozen_string_literal: true

class StatsController < ApplicationController
  before_action :infer_page_title

  skip_before_action :authenticate_user!

  def index
    @total_paid = PaidPfmp.paid.sum(:amount)
    @total_paid_students = PaidPfmp.paid.distinct.count(:student_id)
    @total_paid_pfmps = PaidPfmp.paid.count
  end

  def paid_pfmps_per_month
    render json: PaidPfmp.group_by_month(:paid_at, format: "%B %Y").count
  end
end
