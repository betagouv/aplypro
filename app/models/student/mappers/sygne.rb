# frozen_string_literal: true

class Student
  module Mappers
    class Sygne < Base
      def map_schooling!(classe, student, entry)
        attributes = map_schooling_attributes(entry)
        schooling = Schooling
                    .find_or_initialize_by(classe: classe, student: student)
                    .tap { |sc| sc.assign_attributes(attributes) }
                    .tap(&:save!)

        student.close_current_schooling! if schooling != student.current_schooling

        # we might have an existing closed schooling which needs to be re-opened
        schooling.reopen! if schooling.closed?

        schooling.save!
      end

      def map_schooling_attributes(entry)
        schooling_mapper.new.call(entry).values_at(:status, :start_date)
      rescue StandardError => e
        raise SchoolingParsingError.new, "Schooling parsing failure for #{uai}: #{e.message}"
      end
    end
  end
end
