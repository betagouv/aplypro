# frozen_string_literal: true

class FetchStudentSchoolingsInformationJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(student)
    Updaters::StudentSchoolingsUpdater.call(student)
  end
end
