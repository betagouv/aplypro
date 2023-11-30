# frozen_string_literal: true

class AddIndexOnUserEmailAndProvider < ActiveRecord::Migration[7.1]
  def up
    remove_index :users, name: "index_users_on_email"
    add_index :users, %i[email provider], unique: true, name: "index_users_on_email_and_provider"
  end

  def down
    remove_index :users, name: "index_users_on_email_and_provider"
    add_index :users, :email, unique: true
  end
end
