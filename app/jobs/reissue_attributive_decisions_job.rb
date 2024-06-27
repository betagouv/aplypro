# frozen_string_literal: true

class ReissueAttributiveDecisionsJob < ApplicationJob
  def perform(establishment)
    schoolings = establishment
                   .schoolings

    schoolings.update_all(generating_attributive_decision: true) # rubocop:disable Rails/SkipsModelValidations

    jobs = schoolings.map { |schooling| GenerateAttributiveDecisionsJob.new(schooling) }

    ActiveJob.perform_all_later(jobs)
  end
end
