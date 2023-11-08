# frozen_string_literal: true

class AddOidcAttributesToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :oidc_attributes, :jsonb
  end
end
