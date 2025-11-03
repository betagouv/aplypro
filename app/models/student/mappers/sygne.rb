# frozen_string_literal: true

class Student
  module Mappers
    class Sygne < Base
      def map_schooling!(classe, student, entry)
        attributes = map_schooling_attributes(entry)

        schooling = Schooling
                    .find_or_initialize_by(classe: classe, student: student)
                    .tap { |sc| sc.assign_attributes(attributes) }

        current_schooling_end_date(schooling)

        school_year_is_current = @establishment.in_current_school_year_range?(Date.parse(attributes[:start_date]))
        schooling.reopen! if school_year_is_current && attributes[:end_date].nil?

        schooling.save!
      end

      def map_schooling_attributes(entry)
        schooling_mapper.new.call(entry).slice(:status, :start_date, :end_date)
      end
    end
  end
end
