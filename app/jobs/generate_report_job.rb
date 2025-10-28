# frozen_string_literal: true

class GenerateReportJob < ApplicationJob
  def perform(school_year = SchoolYear.current, date = Time.current)
    Report.create_for_school_year(school_year, date)

    WarmCachesJob.perform_later
    PaidPfmp.refresh
  end
end
