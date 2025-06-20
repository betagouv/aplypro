# frozen_string_literal: true

# Service object that leverages pre-defined API mappers to fetch students from classes
# It uses the ClasseMapper, StudentMapper and SchoolingMapper to extract information from
# the aggregate call for all 3 different models
class Student
  module Mappers
    class Base
      include Student::Mappers::Errors

      attr_reader :payload, :uai, :establishment

      def initialize(payload, uai)
        @payload = payload
        @uai = uai
        @establishment = Establishment.find_by(uai: uai)
      end

      def identifier
        self.class.name.demodulize
      end

      %w[schooling address classe student].each do |klass|
        define_method "#{klass}_mapper" do
          "StudentsApi::#{identifier}::Mappers::#{klass.classify}Mapper".constantize
        end
      end

      def parse!
        map_classes!.each do |classe, entries|
          entries.each do |entry|
            student = map_student!(entry)

            next if student.nil? # ine == nil

            begin
              map_schooling!(classe, student, entry)
            rescue StandardError => e
              raise e unless Rails.env.production?

              Sentry.capture_exception(
                SchoolingParsingError.new(
                  "Schooling parsing failed for entry: #{entry} , for UAI: #{uai} with message: #{e.message}"
                )
              )
            end
          end
        end

        check_missing_students!
      end

      def check_missing_students!
        map_classes!
          .transform_values! { |student_attrs| map_students!(student_attrs) }
          .each do |classe, students|
          missing = classe.active_students - students

          missing.each(&:close_current_schooling!)
        end
      end

      def map_classes!
        payload
          .group_by { |entry| map_classe!(entry) }
          .except(nil)
      end

      def map_classe!(entry)
        label, mef_code, year = map_classe_attributes(entry)

        school_year = SchoolYear.find_by(start_year: year)
        mef = Mef.find_by(code: mef_code, school_year: school_year)

        return if label.nil? || mef.nil? || school_year.nil?

        return if Exclusion.excluded?(uai, mef_code, school_year)

        Classe.find_or_create_by!(
          label:,
          mef:,
          establishment:,
          school_year:
        )
      rescue ClasseParsingError => e
        Sentry.capture_exception(e)

        nil
      end

      def map_students!(students_attrs)
        students_attrs.filter_map { |attrs| map_student!(attrs) }
      end

      def map_student!(attrs)
        attributes = map_student_attributes(attrs)

        return if attributes[:ine].blank?

        Student
          .find_or_initialize_by(ine: attributes[:ine])
          .tap { |student| student.assign_attributes(attributes) }
          .tap(&:save!)
      rescue StudentParsingError => e
        Sentry.capture_exception(e)

        nil
      end

      def map_classe_attributes(attrs)
        classe_mapper.new.call(attrs).values_at(:label, :mef_code, :year)
      rescue StandardError => e
        raise ClasseParsingError.new, "Classe parsing failure for #{uai}: #{e.message}"
      end

      def map_student_attributes(attrs)
        student_mapper.new.call(attrs)
      rescue StandardError => e
        raise StudentParsingError, "Student parsing failure for #{uai}: #{e.message}"
      end

      def inspect
        "#{self.class}<UAI: #{uai}>"
      end

      def current_school_year?(start_date)
        start_date.present? && Date.parse(start_date).year >= SchoolYear.current.start_year
      end
    end
  end
end
