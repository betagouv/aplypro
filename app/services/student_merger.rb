# frozen_string_literal: true

# Service to safely merge duplicate student records (double INE) while preserving data integrity
class StudentMerger
  class StudentMergerError < StandardError; end
  class MissingIneError < StudentMergerError; end
  class InvalidStudentsArrayError < StudentMergerError; end

  attr_reader :students

  def initialize(students)
    @students = students
  end

  def merge!
    ActiveRecord::Base.transaction do
      validate_students!
      determine_target_and_merge_student!
      transfer_asp_individu_id!
      transfer_schoolings!

      @student_to_merge.destroy!

      Rails.logger.info(
        "Merged student #{@student_to_merge.id} into #{@target_student.id}"
      )
      true
    end
  rescue StandardError => e
    Rails.logger.error "Failed to merge students: #{e.message}"
    raise
  end

  private

  def validate_students!
    raise InvalidStudentsArrayError unless students.is_a?(Array) && students.length == 2
    raise MissingIneError if students.any? { |student| student.ine.nil? }
  end

  def determine_target_and_merge_student!
    sorted_students = students.sort_by do |student|
      latest_payment_request = student.pfmps.map(&:latest_payment_request).compact.max_by(&:created_at)
      latest_payment_request&.created_at || Time.at(0)
    end

    @target_student = sorted_students.last  # Keep the student with the most recent payment request
    @student_to_merge = sorted_students.first
  end

  def transfer_asp_individu_id!
    return unless @student_to_merge.asp_individu_id.present?

    @student_to_merge.update!(asp_individu_id: nil)
    @target_student.update!(asp_individu_id: @student_to_merge.asp_individu_id)
  end

  def transfer_schoolings!
    @student_to_merge.schoolings.update_all(student_id: @target_student.id)
  end
end
