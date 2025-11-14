# frozen_string_literal: true

class StatsController < ApplicationController
  before_action :infer_page_title

  skip_before_action :authenticate_user!

  def index
    @current_school_year = SchoolYear.current
    load_stats_from_report if current_report
  end

  private

  def current_report
    @current_report ||= Report
                        .select(:id, :school_year_id, :created_at)
                        .for_school_year(@current_school_year)
                        .ordered
                        .first
  end

  def load_stats_from_report
    stats = Reports::StatsExtractor.new(current_report).extract_public_stats

    @total_paid = stats[:total_paid_amount]
    @total_paid_students = stats[:students_paid_count]
    @total_paid_pfmps = stats[:pfmps_paid_count]

    academy_extractor = Reports::AcademyDataExtractor.new(current_report)
    @schoolings_per_academy = academy_extractor.extract_field(:schoolings_count)
    @amounts_per_academy = academy_extractor.extract_field(:pfmps_validated_sum)
  end
end
