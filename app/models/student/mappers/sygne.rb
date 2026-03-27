# frozen_string_literal: true

class Student
  module Mappers
    class Sygne < Base
      def map_schooling!(classe, student, entry)
        attributes = map_schooling_attributes(entry).slice(:status, :start_date, :end_date)

        schooling = Schooling.find_or_initialize_by(classe: classe, student: student)

        merge_schooling_attributes(schooling, attributes)

        handle_current_schooling_end_date(schooling)

        school_year_is_current = @establishment.in_current_school_year_range?(Date.parse(attributes[:start_date]))
        schooling.reopen! if school_year_is_current && attributes[:end_date].nil?

        schooling.save!
      end
    end
  end
end
