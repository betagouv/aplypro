# frozen_string_literal: true

class GenerateReportJob < ApplicationJob
  queue_as :payments

  def perform(school_year = SchoolYear.current, date = Time.current)
    return if Report.exists?(created_at: date.all_day, school_year: school_year)

    stats_data = generate_stats_data(school_year)
    Report.create!(
      data: stats_data,
      created_at: date,
      school_year: school_year
    )
    WarmCachesJob.perform_later
  end

  private

  def generate_stats_data(school_year)
    start_year = school_year.start_year
    stats = Stats::Main.new(start_year)
    {
      global_data: stats.global_data,
      bops_data: stats.bops_data,
      menj_academies_data: stats.menj_academies_data,
      establishments_data: stats.establishments_data
    }
  end
end
