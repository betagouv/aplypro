class CreateClasses < ActiveRecord::Migration[7.0]
  def change
    create_table :classes do |t|
      t.references :establishment, null: false
      t.references :mefstat, null: false, foreign_key: true
      t.string :label

      t.timestamps
    end
  end
end
