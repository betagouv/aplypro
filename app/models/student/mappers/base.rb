# frozen_string_literal: true

class Student
  module Mappers
    class Base
      include Student::Mappers::Errors

      attr_reader :payload, :uai, :year, :establishment

      def initialize(payload, uai)
        @payload = payload
        @uai = uai
        @establishment = Establishment.find_by(uai: uai)
        @year = Aplypro::SCHOOL_YEAR
      end

      def identifier
        self.class.name.demodulize
      end

      %w[schooling address classe student].each do |klass|
        define_method "#{klass}_mapper" do
          mapper = "StudentsApi::#{identifier}::Mappers::#{klass.classify}Mapper".constantize

          mapper.new
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
              Sentry.capture_exception(
                SchoolingParsingError.new(
                  "Schooling parsing failed for #{uai}: #{e.message}"
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
        label, mef_code = map_classe_attributes(entry)

        mef = Mef.find_by(code: mef_code)

        return if label.nil? || mef.nil?

        return if Exclusion.excluded?(uai, mef_code)

        Classe.find_or_create_by!(
          label:,
          mef:,
          establishment:,
          start_year: @year
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
        classe_mapper.call(attrs).values_at(:label, :mef_code)
      rescue StandardError => e
        raise ClasseParsingError.new, "Classe parsing failure for #{uai}: #{e.message}"
      end

      def map_student_attributes(attrs)
        student_mapper.call(attrs)
      rescue StandardError => e
        raise StudentParsingError, "Student parsing failure for #{uai}: #{e.message}"
      end

      def inspect
        "#{self.class}<UAI: #{uai}>"
      end
    end
  end
end
