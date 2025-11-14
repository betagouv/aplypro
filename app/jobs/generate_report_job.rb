# frozen_string_literal: true

class GenerateReportJob < ApplicationJob
  queue_as :payments

  def perform(school_year = SchoolYear.current, date = Time.current)
    Report.create_for_school_year(school_year, date)

    previous_school_year = SchoolYear.find_by(start_year: school_year.start_year - 1)
    Report.create_for_school_year(previous_school_year, date) if previous_school_year

    WarmCachesJob.perform_later
  end
end
