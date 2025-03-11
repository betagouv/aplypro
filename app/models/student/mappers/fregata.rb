# frozen_string_literal: true

class Student
  module Mappers
    class Fregata < Base
      def map_student_attributes(attrs)
        student_attrs = super

        extra_attrs = address_mapper.new.call(attrs)

        student_attrs.merge!(extra_attrs) if extra_attrs.present?

        student_attrs
      end

      def map_schooling!(classe, student, entry)
        attributes = map_schooling_attributes(entry)
        schooling = Schooling.find_or_initialize_by(classe: classe, student: student)
                             .tap { |sc| sc.assign_attributes(attributes) }

        # TODO: This should be mapped in 'SchoolingMapper' to be consistent (Tried, but failed)
        schooling.end_date = left_classe_at(entry)

        student.close_current_schooling! if schooling.open? && student.current_schooling != schooling

        schooling.save!
      end

      def left_classe_at(entry)
        entry["dateSortieFormation"] || entry["dateSortieEtablissement"]
      end

      def map_schooling_attributes(entry)
        schooling_mapper.new.call(entry).slice(:status, :start_date)
      end
    end
  end
end
