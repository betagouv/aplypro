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
        group_by_classes.each do |classe, entries|
          entries.each do |entry|
            student = map_student!(entry)

            next if student.nil? # ine == nil

            map_schooling!(classe, student, entry)
          end
        end

        check_missing_students!
      end

      def group_by_classes
        payload
          .group_by { |entry| map_classe!(entry) }
          .except(nil)
      end

      def classes_with_students
        group_by_classes.transform_values! { |student_attrs| map_students!(student_attrs) }
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

      def inspect
        "#{self.class}<UAI: #{establishment.uai}>"
      end
    end
  end
end
