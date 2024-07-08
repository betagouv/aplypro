# frozen_string_literal: true

class FetchStudentSchoolingsInformationJob < ApplicationJob
  include FregataProof

  queue_as :default

  discard_on ActiveRecord::RecordNotFound, Student::Mappers::Errors::SchoolingParsingError

  # Sygne rate limiting, 429
  retry_on Faraday::TooManyRequestsError, wait: 1.hour, attempts: 3

  def perform(student)
    # XXX: Sygne temporarily disabled
    return true if (student.establishment.provided_by?(:sygne) && Rails.env.production?) || student.current_schooling.nil?

    Updaters::StudentSchoolingsUpdater.call(student)
  end
end
