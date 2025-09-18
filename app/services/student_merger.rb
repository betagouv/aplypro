# frozen_string_literal: true

# Service to safely merge duplicate student records (double INE) while preserving data integrity
class StudentMerger
  class StudentMergerError < StandardError; end
  class InvalidStudentsArrayError < StudentMergerError; end
  class BothActiveSchoolingsError < StudentMergerError; end
  class StudentNotIdenticalError < StudentMergerError; end

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
      transfer_ribs!

      @student_to_merge.reload
      student_to_merge_id = @student_to_merge.id
      @student_to_merge.destroy!

      Rails.logger.info(
        "Merged student #{student_to_merge_id} into #{@target_student.id}"
      )
      true
    end
  end

  private

  def validate_students!
    raise InvalidStudentsArrayError unless students.is_a?(Array) && students.length == 2
    raise StudentNotIdenticalError unless students_are_duplicates?
  end

  def students_are_duplicates?
    students[0].duplicates.include?(students[1])
  end

  def determine_target_and_merge_student! # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    active_students = students.select { |s| s.schoolings.exists?(end_date: nil) }

    if active_students.size == 2
      raise BothActiveSchoolingsError,
            "Cannot merge when both students have active schoolings"
    end

    if active_students.any?
      @target_student = active_students.first
      @student_to_merge = (students - active_students).first
      return
    end

    sorted_students = students.sort_by do |student|
      latest_payment_request = student.pfmps.map(&:latest_payment_request).compact.max_by(&:created_at)
      latest_payment_request&.created_at || Time.zone.at(0)
    end

    @target_student = sorted_students.last
    @student_to_merge = sorted_students.first
  end

  def transfer_asp_individu_id!
    id = @student_to_merge.asp_individu_id || @target_student.asp_individu_id

    @student_to_merge.update!(asp_individu_id: nil)
    @target_student.update!(asp_individu_id: id)
  end

  def transfer_schoolings!
    @student_to_merge.schoolings.update!(student_id: @target_student.id)
  end

  def transfer_ribs!
    @student_to_merge.ribs.update!(student_id: @target_student.id, archived_at: DateTime.now)
  end
end
