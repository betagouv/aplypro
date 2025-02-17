# frozen_string_literal: true

# Service to safely merge duplicate student records (double INE) while preserving data integrity
class StudentMerger
  class StudentMergerError < StandardError; end
  class InvalidStudentsArrayError < StudentMergerError; end
  class ActiveSchoolingError < StudentMergerError; end
  class StudentNotIdenticalError < StudentMergerError; end

  attr_reader :students

  def initialize(students)
    @students = students
  end

  def merge!
    ActiveRecord::Base.transaction do
      validate_students!
      determine_target_and_merge_student!
      validate_schoolings!
      transfer_asp_individu_id!
      transfer_schoolings!

      @student_to_merge.destroy!

      Rails.logger.info(
        "Merged student #{@student_to_merge.id} into #{@target_student.id}"
      )
      true
    end
  end

  private

  def validate_students!
    raise InvalidStudentsArrayError unless students.is_a?(Array) && students.length == 2
    raise StudentNotIdenticalError unless students[0] == students[1]
  end

  def determine_target_and_merge_student!
    sorted_students = students.sort_by do |student|
      latest_payment_request = student.pfmps.map(&:latest_payment_request).compact.max_by(&:created_at)
      latest_payment_request&.created_at || Time.zone.at(0)
    end

    @target_student = sorted_students.last
    @student_to_merge = sorted_students.first
  end

  def validate_schoolings!
    return unless @student_to_merge.schoolings.exists?(end_date: nil)

    raise ActiveSchoolingError, "Cannot merge students with active schoolings"
  end

  def transfer_asp_individu_id!
    id = @student_to_merge.asp_individu_id || @target_student.asp_individu_id

    @student_to_merge.update!(asp_individu_id: nil)
    @target_student.update!(asp_individu_id: id)
  end

  def transfer_schoolings!
    @student_to_merge.schoolings.update!(student_id: @target_student.id)
  end
end
