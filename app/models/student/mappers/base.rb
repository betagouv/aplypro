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
        classes_with_students.each do |classe, students|
          students.each do |student|
            if !Schooling.find_by(classe: classe, student: student)
              student.close_current_schooling!
              Schooling.create(classe: classe, student: student)
            end
          end
        end

        check_schoolings!
        check_missing_students!
      end

      def classes_with_students
        payload
          .group_by { |entry| map_classe!(entry) }
          .reject { |classe, _attrs| classe.nil? }
          .transform_values! { |student_attrs| map_students!(student_attrs) }
      end

      def map_classe!(entry)
        label, mef_code = self.class::ClasseMapper.new.call(entry).values_at(:label, :mef_code)

        mef = Mef.find_by(code: mef_code)

        return if label.nil? || mef.nil?

        Classe.find_or_create_by!(
          label:,
          mef:,
          establishment: establishment,
          start_year: @year
        )
      end

      def map_students!(students_attrs)
        students_attrs.filter_map { |attrs| map_student!(attrs) }
      end

      def map_student!(attrs)
        attributes = map_student_attributes(attrs)

        return if attributes[:ine].nil?

        Student
          .find_or_initialize_by(ine: attributes[:ine])
          .tap { |student| student.assign_attributes(attributes) }
          .tap(&:save!)
      end

      def check_missing_students!
        classes_with_students.each do |classe, students|
          missing = classe.active_students - students

          missing.each(&:close_current_schooling!)
        end
      end

      def map_student_attributes(attrs)
        self.class::StudentMapper.new.call(attrs)
      end

      def check_schoolings!
        payload
          .filter { |entry| student_has_left_class?(entry) && find_existing_student(entry) }
          .map    { |entry| [entry, find_existing_student(entry)] }
          .each   { |entry, student| student.close_current_schooling!(left_classe_at(entry)) }
      end

      def find_existing_student(entry)
        Student.find_by(ine: map_student_attributes(entry)[:ine])
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

      def student_has_left_class?(entry)
        student_has_changed_class?(entry) || student_has_left_establishment?(entry)
      end

      def inspect
        "#{self.class}<UAI: #{establishment.uai}>"
      end
    end
  end
end
