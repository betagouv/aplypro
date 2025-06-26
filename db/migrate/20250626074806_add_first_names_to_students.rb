class AddFirstNamesToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :first_name2, :string, null: true
    add_column :students, :first_name3, :string, null: true
  end
end
