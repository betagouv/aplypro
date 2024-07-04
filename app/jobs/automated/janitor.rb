# frozen_string_literal: true

class Janitor < ApplicationJob

  def perform
    # remove_ghost_schoolings
    reset_attributive_decision_version_overflow
  end

  private
  def remove_ghost_schoolings
    duplicate_student_ids = Schooling.group(:student_id).having("count(student_id) > 1").pluck(:student_id)

    duplicate_schoolings = Schooling.where(student_id: duplicate_student_ids)

    pfmp_counts = duplicate_schoolings.map do |schooling|
      { schooling: schooling, pfmp_count: schooling.pfmps.count }
    end

    # Delete the filtered schoolings
    Schooling.where(id: sco_ids_to_delete).delete_all
  end

  def reset_attributive_decision_version_overflow
    Schooling.where('attributive_decision_version > ?', 9).update_all(attributive_decision_version: 9)
  end

end