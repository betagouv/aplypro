# frozen_string_literal: true

module Generate
  class AttributiveDecisionsJob < ApplicationJob
    def perform(schoolings)
      jobs = schoolings.map { |schooling| Generate::AttributiveDecisionJob.new(schooling) }

      ActiveJob.perform_all_later(jobs)
    end
  end
end
