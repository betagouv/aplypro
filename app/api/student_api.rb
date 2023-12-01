# frozen_string_literal: true

module StudentApi
  class << self
    def fetch_students!(establishment)
      api_for(establishment).fetch_and_parse!
    end

    def fetch_student_data!(student)
      api_for(student.current_schooling.establishment).fetch_student_data!(student.ine)
    end

    def api_for(establishment)
      case establishment.students_provider
      when "sygne"
        Sygne.new(establishment)
      when "fregata"
        Fregata.new(establishment)
      else
        raise "Provider has no matching API"
      end
    end
  end
end
