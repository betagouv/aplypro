class AddUniqueConstraintToWages < ActiveRecord::Migration[8.0]
  def change
    add_index :wages, [:mefstat4, :ministry, :daily_rate, :yearly_cap, :school_year_id],
              unique: true,
              name: 'index_wages_on_core_attributes'
  end
end
