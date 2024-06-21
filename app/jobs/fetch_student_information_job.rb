# frozen_string_literal: true

class FetchStudentInformationJob < ApplicationJob
  queue_as :default

  def perform(schooling) # rubocop:disable Metrics/AbcSize
    student = schooling.student

    return if student.ine_not_found || schooling.closed?

    api = schooling.establishment.students_api

    api.fetch_resource(:student, ine: schooling.student.ine)
       .then { |data| map_student_attributes(data, api) }
       .then { |attributes| student.update!(attributes) }

    FetchStudentSchoolingsInformationJob.perform_later(student) if Rails.env.production?
  rescue Faraday::ResourceNotFound
    schooling.student.update!(ine_not_found: true)
  end

  private

  def map_student_attributes(data, api)
    student_attributes = api.student_mapper.new.call(data)
    address_attributes = api.address_mapper.new.call(data)

    student_attributes
      .merge(address_attributes)
      .slice(*Student.updatable_attributes)
      .except(:ine)
  end
end
