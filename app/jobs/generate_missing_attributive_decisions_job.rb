# frozen_string_literal: true

class GenerateMissingAttributiveDecisionsJob < ApplicationJob
  around_perform do |job, block|
    establishment = job.arguments.first

    establishment.update!(generating_attributive_decisions: true)

    block.call

    establishment.update!(generating_attributive_decisions: false)
  end

  def perform(establishment)
    establishment
      .current_schoolings
      .without_attributive_decisions
      .each { |schooling| GenerateAttributiveDecisionJob.perform_now(schooling) }
  end
end
