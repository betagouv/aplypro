# frozen_string_literal: true

class GenerateMissingAttributiveDecisionsJob < ApplicationJob
  around_perform do |job, block|
    establishment = job.arguments.first

    establishment.update!(generating_attributive_decisions: true)

    block.call

    establishment.update!(generating_attributive_decisions: false)
  end

  def perform(establishment)
    jobs = establishment
           .current_schoolings
           .without_attributive_decisions
           .map { |schooling| GenerateAttributiveDecisionJob.new(schooling) }

    ActiveJob.perform_all_later(jobs)
  end
end
