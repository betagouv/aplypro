# frozen_string_literal: true

module Sync
  class StudentJob < ApplicationJob
    queue_as :default

    def perform(schooling)
      student = schooling.student

      return true if schooling.establishment.provided_by?(:sygne) && Rails.env.production?
      return true if student.ine_not_found || schooling.closed?

      # TODO: Ce morceau de code ne doit pas rester là !
      # Si la scolarité actuelle n'est pas dans la liste des scolarités de l'élève dans APLyPro
      # et que son statut n'est pas "ST" et que la date de fin de la scolarité est nulle
      if student.schoolings.exclude?(schooling) && !schooling.status.eql?(:student) && schooling.end_date.nil?
        schooling.end_date = Time.zone.today
      end

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
