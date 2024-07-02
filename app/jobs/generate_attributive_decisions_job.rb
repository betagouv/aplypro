# frozen_string_literal: true

class GenerateAttributiveDecisionsJob < ApplicationJob
  def perform(schoolings)
    Schooling.transaction { schoolings.each { |s| s.update!(generating_attributive_decision: true) } }

    jobs = schoolings.map { |schooling| GenerateAttributiveDecisionJob.new(schooling) }

    ActiveJob.perform_all_later(jobs)
  end
end
