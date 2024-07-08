# frozen_string_literal: true

module Sync
  class StudentJob < ApplicationJob
    queue_as :default

    def perform(schooling)
      student = schooling.student

      return if student.ine_not_found || schooling.closed?

      fetch_student_data(schooling)

      Sync::StudentSchoolingsJob.perform_later(student) if Rails.env.production?
    rescue Faraday::ResourceNotFound
      schooling.student.update!(ine_not_found: true)
    end

    private

    def fetch_student_data(schooling)
      api = schooling.establishment.students_api
      api.fetch_resource(:student, ine: schooling.student.ine)
         .then { |data| map_student_attributes(data, api) }
         .then { |attributes| schooling.student.update!(attributes) }
    end

    def map_student_attributes(data, api)
      student_attributes = api.student_mapper.new.call(data)
      address_attributes = api.address_mapper.new.call(data)

      student_attributes
        .merge(address_attributes)
        .slice(*Student.updatable_attributes)
        .except(:ine)
    end
  end
end
