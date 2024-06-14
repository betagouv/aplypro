# frozen_string_literal: true

class Student
  module Mappers
    class Fregata < Base
      def map_student_attributes(attrs)
        student_attrs = super(attrs)

        extra_attrs = address_mapper.new.call(attrs)

        student_attrs.merge!(extra_attrs) if extra_attrs.present?

        student_attrs
      end

      def map_schooling!(classe, student, entry)
        schooling = Schooling.find_or_initialize_by(classe: classe, student: student)

        schooling_attributes = schooling_mapper.new.call(entry)

        # TODO: shouldnt this be mapped in schooling_attributes instead to be consistent?
        schooling.start_date = entry["dateEntreeFormation"]
        schooling.end_date = left_classe_at(entry)

        schooling.status = schooling_attributes[:status]

        student.close_current_schooling! if schooling.open? && student.current_schooling != schooling

        schooling.save!
      end

      def left_classe_at(entry)
        entry["dateSortieFormation"] || entry["dateSortieEtablissement"]
      end
    end
  end
end
