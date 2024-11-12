# frozen_string_literal: true

class GenerateAttributiveDecisionsJob < ApplicationJob
  def perform(schoolings)
    jobs = schoolings.map { |schooling| GenerateAttributiveDecisionJob.new(schooling) }

    ActiveJob.perform_all_later(jobs)
  end
end
