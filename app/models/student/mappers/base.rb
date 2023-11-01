# frozen_string_literal: true

class Student
  module Mappers
    class Base
      attr_reader :payload, :establishment, :year

      def initialize(payload, establishment)
        @payload = payload
        @establishment = establishment
        @year = ENV.fetch("APLYPRO_SCHOOL_YEAR")
      end

      def parse!
        classes_with_students.each do |classe, students_attrs|
          map_students(students_attrs).each do |student|
            Schooling.find_or_create_by!(classe: classe, student: student)
          end
        end

        check_schoolings!
      end

      def check_schoolings!
        payload
          .map { |entry| [entry, Student.find_by(ine: map_student_attributes(entry)[:ine])] }
          .each do |entry, student|
          if no_class_for_entry?(entry)
            student.current_schooling.update!(end_date: Time.zone.today)
            student.update!(current_schooling: nil)
          end
        end
      end

      def map_students(payload)
        payload.map do |attrs|
          attributes = map_student_attributes(attrs)

          next if attributes[:ine].nil?

          Student
            .find_or_initialize_by(ine: attributes[:ine])
            .tap { |student| student.assign_attributes(attributes) }
            .tap(&:save!)
        end.compact
      end

      def chop_mef_code(code)
        code.slice(..-2)
      end

      def inspect
        "#{self.class}<UAI: #{establishment.uai}>"
      end
    end
  end
end
