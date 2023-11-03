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
        payload
          .group_by { |entry| map_classe!(entry) }
          .reject { |classe, _attrs| classe.nil? }
          .transform_values! { |student_attrs| map_students!(student_attrs) }
          .each do |classe, students|
          students.each do |student|
            Schooling.find_or_create_by!(classe: classe, student: student)
          end
        end

        check_schoolings!
      end

      def map_classe!(entry)
        label = classe_label(entry)
        code  = classe_mef_code(entry)

        mef = Mef.find_by(code: chop_mef_code(code))

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

      def map_student_attributes(attrs)
        self.class::STUDENT_MAPPING.transform_values do |path|
          attrs.dig(*path.split("."))
        end
      end

      def check_schoolings!
        payload
          .filter { |entry| student_is_gone?(entry) }
          .filter_map { |entry| Student.find_by(ine: map_student_attributes(entry)[:ine]) }
          .each(&:close_current_schooling!)
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
