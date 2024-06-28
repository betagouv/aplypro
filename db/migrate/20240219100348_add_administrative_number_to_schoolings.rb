# frozen_string_literal: true

class AddAdministrativeNumberToSchoolings < ActiveRecord::Migration[7.1]
  # rubocop:disable Metrics/AbcSize
  def migrate_single_attributive_decision!
    students = Student
               .joins(:schoolings)
               .merge(Schooling.with_attributive_decisions)
               .group(:id)
               .having("count(schoolings.id) = 1")
               .pluck(:id, :asp_file_reference)
               .to_h

    Schooling
      .with_attributive_decisions
      .where(student_id: students.keys, administrative_number: nil)
      .find_in_batches.with_index do |models, idx|
      Rails.logger.debug { "processing batch #{idx}..." }

      models.each { |schooling| schooling.administrative_number = students[schooling.student_id] }

      Schooling.upsert_all(models.map(&:attributes), update_only: [:administrative_number]) # rubocop:disable Rails/SkipsModelValidations
    end
  end
  # rubocop:enable Metrics/AbcSize

  def migrate_multiple_attributive_decisions!
    Schooling
      .with_attributive_decisions
      .where(administrative_number: nil)
      .find_in_batches do |schoolings|
      jobs = schoolings.map { |schooling| GenerateAttributiveDecisionJob.perform_later(schooling) }

      ActiveJob.perform_all_later(jobs)
    end
  end

  def up
    add_column :schoolings, :administrative_number, :string

    migrate_single_attributive_decision!
    migrate_multiple_attributive_decisions!

    add_index :schoolings, :administrative_number, unique: true
  end

  def down
    remove_column :schoolings, :administrative_number
  end
end
