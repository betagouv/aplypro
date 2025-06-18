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

        school_year_is_current = current_school_year?(attributes[:start_date])

        attributes.delete(:end_date) unless school_year_is_current

        schooling = Schooling.find_or_initialize_by(classe: classe, student: student)
                             .tap { |sc| sc.assign_attributes(attributes) }

        if school_year_is_current && schooling.open? && student.current_schooling != schooling
          student.close_current_schooling!
        end

        schooling.save!
      end

      def map_schooling_attributes(entry)
        schooling_mapper.new.call(entry)
      end
    end
  end
end
