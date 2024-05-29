# frozen_string_literal: true

class FetchStudentInformationJob < ApplicationJob
  queue_as :default

  def perform(schooling)
    student = schooling.student

    return if student.ine_not_found

    fetch_student_data(schooling).then do |data|
      student_attributes = api.student_mapper.call(data)
      address_attributes = api.address_mapper.call(data)

      attributes = student_attributes.merge(address_attributes)

      student.update!(attributes.slice(*Student.updatable_attributes))
    end
  rescue Faraday::ResourceNotFound
    schooling.student.update!(ine_not_found: true)
  end

  private

  def fetch_student_data(schooling)
    establishment = schooling.establishment

    establishment
      .students_api
      .fetch_student_data!(schooling.student.ine)
  end

  def update_student!(schooling, mapper)
    return if mapper.attributes.blank?

    schooling.student.update!(mapper.attributes)
  end

  def update_schooling!(mapper)
    schooling = find_schooling(mapper)

    return if schooling.nil?

    attributes = mapper
                 .schooling_attributes
                 .slice(*Schooling.attribute_names.map(&:to_sym))

    schooling.update!(attributes)
  end

  def find_schooling(mapper)
    mapper.schooling_finder_attributes => { uai:, label:, mef_code:, ine: }

    Schooling
      .joins(:establishment, :student, [classe: :mef])
      .where("establishments.uai" => uai)
      .where("classe.label" => label)
      .where("mef.code" => mef_code)
      .find_by("student.ine" => ine)
  end
end
