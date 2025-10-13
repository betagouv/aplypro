class CreateStatistics < ActiveRecord::Migration[8.0]
  def change
    create_table :statistics do |t|
      t.references :school_year, null: false, foreign_key: true

      t.string :bop
      t.string :academy_code
      t.string :academy_label

      t.integer :schoolings
      t.integer :edited_da

      t.integer :students
      t.integer :students_with_rib
      t.integer :students_with_data

      t.integer :pfmps
      t.integer :validated_pfmps
      t.integer :validated_pfmps_amount
      t.integer :completed_pfmps
      t.integer :completed_pfmps_amount
      t.integer :incomplete_pfmps
      t.integer :theoretical_incomplete_pfmps_amount
      t.integer :invalid_pfmps
      t.integer :theoretical_invalid_pfmps_amount

      t.integer :asp_payments_paid
      t.integer :asp_payments_paid_amount
      t.integer :paid_students
      t.integer :paid_pfmps
      t.integer :payable_pfmps

      t.integer :reported_da
      t.integer :reported_da_amount

      t.timestamps
    end
  end
end
