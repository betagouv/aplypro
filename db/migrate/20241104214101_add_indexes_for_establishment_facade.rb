class AddIndexesForEstablishmentFacade < ActiveRecord::Migration[7.2]
  def change
    add_index :asp_payment_requests, [:pfmp_id, :created_at]
    add_index :classes, [:establishment_id, :school_year_id]
    add_index :schoolings, [:student_id, :end_date, :removed_at]
  end
end
