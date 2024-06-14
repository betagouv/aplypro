# frozen_string_literal: true

class FetchStudentSchoolingsInformationJob < ApplicationJob
  include FregataProof

  queue_as :default

  discard_on ActiveRecord::RecordNotFound, Student::Mappers::Errors::SchoolingParsingError

  def perform(student)
    return true unless student.current_schooling

    Updaters::StudentSchoolingsUpdater.call(student)
  end
end
