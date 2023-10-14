# frozen_string_literal: true

class AddUniqueIndexOnEstablishmentUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :establishment_users, %i[establishment_id user_id role], unique: true
  end
end
