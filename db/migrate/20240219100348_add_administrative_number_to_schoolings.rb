# frozen_string_literal: true

class AddAdministrativeNumberToSchoolings < ActiveRecord::Migration[7.1]
  def migrate_single_attributive_decision!
    Student
      .joins(:schoolings)
      .merge(Schooling.with_attributive_decisions)
      .group(:id)
      .having("count(schoolings.id) < 2")
      .find_each do |student|
      # unclear whether `student.schoolings` is cached and has the
      # filter applied so reapply the scope to make sure we target the
      # right schooling
      student.schoolings.with_attributive_decisions.first.update!(administrative_number: student.asp_file_reference)
    end
  end

  def migrate_multiple_attributive_decisions!
    Schooling
      .with_attributive_decisions
      .where(administrative_number: nil)
      .find_each do |schooling|
      GenerateAttributiveDecisionJob.perform_later(schooling)
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
