class CreateMefstats < ActiveRecord::Migration[7.0]
  def change
    create_table :mefstats do |t|
      t.string :label, null: false
      t.string :short, null: false

      t.timestamps
    end
  end
end
