# frozen_string_literal: true

module Updaters
  class StudentSchoolingsUpdater
    attr_reader :student

    class << self
      def call(student)
        new(student).call
      end
    end

    def initialize(student)
      @student = student
    end

    def call
      mapped_schooling_data.each do |attributes|
        school_year = SchoolYear.find_by(start_year: attributes[:school_year])

        classe = Classe.find_by(
          establishment: Establishment.find_by(uai: attributes[:uai]),
          school_year:,
          label: attributes[:label],
          mef: Mef.find_by(code: attributes[:mef_code], school_year:)
        )

        next if classe.nil?

        Schooling
          .find_by!(classe: classe, student: student)
          .update(attributes.slice(*Schooling.updatable_attributes))
      end
    end

    private

    def api
      student.establishment.students_api
    end

    def mapped_schooling_data
      api
        .fetch_resource(:student_schoolings, ine: student.ine)
        .map { |entry| api.schooling_mapper.new.call(entry) }
        .compact
    end
  end
end
