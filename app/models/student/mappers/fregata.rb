# frozen_string_literal: true

class Student
  module Mappers
    class Fregata < Base
      def map_classes!
        return {} if payload.nil?

        filtered_payload = payload.reject { |entry| entry["estEN"] == true }
        grouped_by_classe = filtered_payload.group_by { |entry| map_classe!(entry) }
        grouped_by_classe.reject! { |classe, entries| classe.nil? || all_menj_students?(classe, entries) }
        grouped_by_classe
      end

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

        handle_current_schooling_end_date(schooling)

        schooling.save!
      end

      def map_schooling_attributes(entry)
        schooling_mapper.new.call(entry)
      end

      private

      def all_menj_students?(classe, entries)
        return false if classe.nil?

        original_entries_for_classe = payload.select { |entry| map_classe!(entry) == classe }
        entries.empty? && original_entries_for_classe.any?
      end
    end
  end
end
