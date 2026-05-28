# frozen_string_literal: true

class Student
  module Mappers
    class CSV < Base
      def map_schooling!(classe, student, entry)
        return if entry["date_début"].present? && Date.parse(entry["date_début"]) > Date.current

        schooling = Schooling.find_or_initialize_by(classe: classe, student: student) do |sc|
          sc.start_date = entry["date_début"]
          sc.end_date = entry["date_fin"]
          sc.status = :student
        end

        handle_current_schooling_end_date(schooling)

        schooling.save!
      end
    end
  end
end
