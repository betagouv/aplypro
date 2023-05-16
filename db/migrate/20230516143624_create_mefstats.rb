class CreateMefstats < ActiveRecord::Migration[7.0]
  def change
    create_table :mefstats do |t|
      t.integer :code, null: false
      t.string :label, null: false
      t.string :short, null: false

      t.timestamps
    end

    add_index :mefstats, :code, unique: true
  end
end
