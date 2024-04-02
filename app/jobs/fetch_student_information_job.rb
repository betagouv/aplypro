# frozen_string_literal: true

class FetchStudentInformationJob < ApplicationJob
  queue_as :default

  def perform(schooling)
    establishment = schooling.establishment
    student = schooling.student

    api = StudentApi.api_for(establishment.students_provider, establishment.uai)

    api
      .fetch_student_data!(student.ine)
      .then do |data|
      mapper = api.info_mapper.new(data, establishment.uai)

      update_student!(schooling, mapper)
      update_schooling!(mapper)
    end
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
