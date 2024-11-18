# frozen_string_literal: true

module Sync
  class StudentSchoolingsJob < ApplicationJob
    include FregataProof

    queue_as :default

    discard_on ActiveRecord::RecordNotFound, Student::Mappers::Errors::SchoolingParsingError

    # Sygne rate limiting, 429
    retry_on Faraday::TooManyRequestsError, wait: 1.hour, attempts: 3

    def perform(student)
      return true if student.not_to_be_synced?

      Updaters::StudentSchoolingsUpdater.call(student)
    end
  end
end
