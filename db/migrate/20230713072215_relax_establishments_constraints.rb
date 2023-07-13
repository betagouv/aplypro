class RelaxEstablishmentsConstraints < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:establishments, :name, true)
    change_column_null(:establishments, :denomination, true)
    change_column_null(:establishments, :nature, true)
  end
end
