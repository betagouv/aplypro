# frozen_string_literal: true

class GenerateMissingAttributiveDecisionsJob < ApplicationJob
  def perform(establishment, school_year)
    schoolings = establishment.schoolings.without_attributive_decisions
                              .joins(:classe)
                              .where(classe: { school_year: school_year })

    schoolings.update_all(generating_attributive_decision: true) # rubocop:disable Rails/SkipsModelValidations

    jobs = schoolings.map { |schooling| GenerateAttributiveDecisionJob.new(schooling) }

    ActiveJob.perform_all_later(jobs)
  end
end
