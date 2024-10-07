# frozen_string_literal: true

module Sync
  class StudentSchoolingsJob < ApplicationJob
    include FregataProof

    queue_as :default

    discard_on ActiveRecord::RecordNotFound, Student::Mappers::Errors::SchoolingParsingError

    # Sygne rate limiting, 429
    retry_on Faraday::TooManyRequestsError, wait: 1.hour, attempts: 3

    def perform(student)
      # There are students with no schoolings at all
      # Student.where.missing(:schoolings).count
      return true if student.establishment.blank?

      # XXX: Sygne temporarily disabled see issue:
      # https://github.com/orgs/betagouv/projects/71/views/1?pane=issue&itemId=70119483
      if (student.establishment.provided_by?(:sygne) && Rails.env.production?) || student.current_schooling.nil?
        return true
      end

      return true if student.current_schooling.removed?

      Updaters::StudentSchoolingsUpdater.call(student)
    end
  end
end
