# frozen_string_literal: true

class GenerateAttributiveDecisionsJob < ApplicationJob
  def perform(schooling_ids)

    schoolings = Schooling.where(id: schooling_ids)

    schoolings.update_all(generating_attributive_decision: true) # rubocop:disable Rails/SkipsModelValidations

    jobs = schoolings.map { |schooling| GenerateAttributiveDecisionJob.new(schooling) }

    ActiveJob.perform_all_later(jobs)
  end
end
