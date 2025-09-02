class CreateInseeExceptionCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :insee_exception_codes do |t|
      t.string :code_type, null: false
      t.string :entry_code, null: false
      t.string :exit_code, null: false
      t.date :expired_at

      t.timestamps

      t.index :entry_code, unique: true
    end
  end
end
