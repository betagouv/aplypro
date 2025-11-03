# frozen_string_literal: true

class StatsController < ApplicationController
  before_action :infer_page_title

  skip_before_action :authenticate_user!

  def index # rubocop:disable Metrics/AbcSize
    @total_paid = PaidPfmp.paid.sum(:amount)
    @total_paid_students = PaidPfmp.paid.distinct.count(:student_id)
    @total_paid_pfmps = PaidPfmp.paid.count

    current_year = SchoolYear.current.start_year

    @schoolings_per_academy = Rails.cache.fetch("schoolings_per_academy/#{current_year}", expires_in: 1.week) do
      schoolings_stats = Stats::Indicator::Count::Schoolings.new(current_year)
      academies_data(schoolings_stats, :count)
    end

    @amounts_per_academy = Rails.cache.fetch("amounts_per_academy/#{current_year}", expires_in: 1.week) do
      sendable_amounts_stats = Stats::Indicator::Sum::PfmpsSendable.new(current_year)
      academies_data(sendable_amounts_stats, :sum)
    end
  end

  def paid_pfmps_per_month
    render json: PaidPfmp.group_by_month(:paid_at, format: "%B %Y").count
  end

  private

  def academies_data(stats_indicator, operation_type)
    collection = stats_indicator.with_mef_and_establishment
                                .where("mefs.ministry": :menj)

    if operation_type == :count
      collection.group("establishments.academy_code").count
    else
      collection.group("establishments.academy_code").sum(:amount)
    end
  end
end
