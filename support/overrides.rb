# frozen_string_literal: true

class Pfmp < ApplicationRecord
  def describe
    [id: id, start_date: start_date.to_s, end_date: end_date.to_s, day_count: day_count, amount: amount]
  end
end

class Schooling < ApplicationRecord
  def describe
    [id: id, start_date: start_date.to_s, end_date: end_date.to_s,
     status: status, student_id: student.id, classe_id: classe.id]
  end
end

class Student < ApplicationRecord
  def describe
    [id: id, ine: ine, first_name: first_name, last_name: last_name,
     birthdate: birthdate.to_s, current_schooling: current_schooling.describe]
  end
end
