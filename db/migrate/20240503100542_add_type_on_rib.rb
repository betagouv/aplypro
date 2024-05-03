# frozen_string_literal: true

class AddTypeOnRib < ActiveRecord::Migration[7.1]
  def up
    # NOTE: previously we had a `personal` boolean for RIBs
    # belonging to the student (true), or someone else (false). It
    # was defaulted to `false`, which means we must keep the logic
    # with 1 here which is the value of our the enum value for
    # `other_person`. See commit.
    add_column :ribs, :owner_type, :integer, default: 1

    Rib.where(personal: true).update(owner_type: :personal)

    change_column_null :ribs, :owner_type, false

    remove_column :ribs, :personal
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
