# frozen_string_literal: true

class FetchStudentInformationJob < ApplicationJob
  queue_as :default

  def perform(student)
    establishment = student.current_schooling.establishment

    api = StudentApi.api_for(establishment.students_provider, establishment.uai)

    api
      .fetch_student_data!(student.ine)
      .then do |data|
      mapper = api.info_mapper.new(data)

      if mapper.attributes.present?
        student.assign_attributes(mapper.attributes)
        student.save!
      end
    end
  end
end
