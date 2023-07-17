class ReworkMefstatTable < ActiveRecord::Migration[7.0]
  def change
    rename_table(:mefstats, :mefs)

    change_table :mefs, bulk: true do |t|
      # this isn't reversible but we'll bulk all the migrations
      # together closer to production anyway.

      # change code to a string, and add mefstat11 : both could be
      # integer types but they are string of digits, not numbers
      t.change :code, :string, null: false, index: true # rubocop:disable Rails/ReversibleMigration
      t.string :mefstat11, null: false, index: true
    end

    rename_column(:classes, :mefstat_id, :mef_id)
  end
end
