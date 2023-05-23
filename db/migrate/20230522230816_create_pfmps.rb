class CreatePfmps < ActiveRecord::Migration[7.0]
  def change
    create_table :pfmps do |t|
      t.date :start_date
      t.date :end_date
      t.timestamps
    end

    add_column :pfmps, :student_id, :string, null: false
    add_foreign_key :pfmps, :students, primary_key: "ine"
  end
end
