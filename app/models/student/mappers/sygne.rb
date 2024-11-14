# frozen_string_literal: true

class Student
  module Mappers
    class Sygne < Base
      def map_schooling!(classe, student, entry)
        attributes = map_schooling_attributes(entry)
        schooling = Schooling
                    .find_or_initialize_by(classe: classe, student: student)
                    .tap { |sc| sc.assign_attributes(attributes) }

        if schooling.open?
          student.close_current_schooling! if student.current_schooling != schooling
        elsif attributes[:end_date].nil?
          schooling.reopen!
        end

        schooling.save!
      end

      def map_schooling_attributes(entry)
        schooling_mapper.new.call(entry).slice(:status, :start_date, :end_date)
      end
    end
  end
end
