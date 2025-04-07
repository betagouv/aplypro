# frozen_string_literal: true

module Generate
  class AttributiveDecisionsJob < ApplicationJob
    attr_reader :uai

    def perform(schoolings)
      @uai = schoolings.first.establishment.uai

      jobs = schoolings.map { |schooling| Generate::AttributiveDecisionJob.new(schooling) }

      ActiveJob.perform_all_later(jobs)
    end

    private

    def sync_data
      UpdateConfirmedDirectorJob.new.perform(uai)
    end
  end
end
