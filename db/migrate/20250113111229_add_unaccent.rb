class AddUnaccent < ActiveRecord::Migration[7.2]
  def change
    enable_extension "unaccent"
  end
end
