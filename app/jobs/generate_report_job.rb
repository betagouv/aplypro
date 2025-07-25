# frozen_string_literal: true

class GenerateReportJob < ApplicationJob
  queue_as :payments

  def perform(date = Time.current)
    Report.create_for_date(date)
  end
end
