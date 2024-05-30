# frozen_string_literal: true

class Student
  module Mappers
    class Sygne < Base
      def map_schooling!(classe, student, _entry)
        schooling = Schooling.find_or_initialize_by(classe: classe, student: student)

        student.close_current_schooling! if schooling != student.current_schooling

        # we might have an existing closed schooling which needs to be re-opened
        schooling.reopen! if schooling.closed?

        schooling.save!
      end
    end
  end
end
