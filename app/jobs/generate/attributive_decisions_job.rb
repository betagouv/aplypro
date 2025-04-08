# frozen_string_literal: true

module Generate
  class AttributiveDecisionsJob < ApplicationJob
    attr_reader :uai

    RESCUED_RUA_ERRORS = [
      UpdateConfirmedDirectorJob::MultipleDirector,
      UpdateConfirmedDirectorJob::NoListedDirector,
      JSON::ParserError
    ].freeze

    def perform(schoolings)
      establishment = schoolings.first.establishment
      @uai = establishment.uai

      sync_director if establishment.ministry == "menj"

      jobs = schoolings.map { |schooling| Generate::AttributiveDecisionJob.new(schooling) }

      ActiveJob.perform_all_later(jobs)
    end

    private

    def sync_director
      UpdateConfirmedDirectorJob.new.perform(uai)
    rescue *RESCUED_RUA_ERRORS
      Rails.logger.info(
        "No director role found in RUA for UAI: #{uai}"
      )
    end
  end
end
