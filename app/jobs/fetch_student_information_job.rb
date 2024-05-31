# frozen_string_literal: true

class FetchStudentInformationJob < ApplicationJob
  queue_as :default

  def perform(schooling)
    student = schooling.student

    return if student.ine_not_found

    api = schooling.establishment.students_api

    api.fetch_resource(:student, ine: schooling.student.ine)
       .then { |data| map_student_attributes(data, api) }
       .then { |attributes| student.update!(attributes) }
  rescue Faraday::ResourceNotFound
    schooling.student.update!(ine_not_found: true)
  end

  private

  def map_student_attributes(data, api)
    student_attributes = api.student_mapper.call(data)
    address_attributes = api.address_mapper.call(data)

    student_attributes
      .merge(address_attributes)
      .slice(*Student.updatable_attributes)
      .except(:ine)
  end
end
