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
          .filter { |entry| no_class_for_entry?(entry) }
          .map    { |entry| Student.find_by(ine: map_student_attributes(entry)[:ine]) }
          .each(&:close_current_schooling!)
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

      # the MEF codes from SYGNE and FREGATA all arrive with an extra
      # character that seems to be used for academic vs national
      # diplomas[1]. Chomp the extra bit since all of our MEFs (which
      # we prepopulate through data/mefs.csv) are 10 characters long.
      #
      # [1]: https://bv.ac-nantes.fr/affelnet-lycee-resultatsetab/aide/104-ecr-formations.htm
      def chop_mef_code(code)
        code.chop
      end

      def inspect
        "#{self.class}<UAI: #{establishment.uai}>"
      end
    end
  end
end
