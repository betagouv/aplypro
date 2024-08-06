class AddExtendedEndDateToSchoolings < ActiveRecord::Migration[7.1]
  def change
    add_column :schoolings, :extended_end_date, :date, default: nil
  end
end
