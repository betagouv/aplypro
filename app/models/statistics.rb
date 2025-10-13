# frozen_string_literal: true

class Statistics < ApplicationRecord
  scope :global, -> { where(bop: nil, academy_code: nil, academy_label: nil) }
  scope :academy, -> { where.not(bop: nil, academy_code: nil, academy_label: nil) }
  scope :bop, -> { where.not(bop: nil).where(academy_code: nil, academy_label: nil) }
  scope :establishment, -> { where(bop: nil).where.not(academy_code: nil, academy_label: nil) }

  def edited_da_percentage
    edited_da.percent_of(schoolings)
  end

  def students_with_rib_percentage
    students_with_rib.percent_of(students)
  end

  def students_with_data_percentage
    students_with_data.percent_of(students)
  end

  def paid_students_percentage
    paid_students.percent_of(students)
  end

  def paid_pfmps_percentage
    paid_pfmps.percent_of(payable_pfmps)
  end
end
