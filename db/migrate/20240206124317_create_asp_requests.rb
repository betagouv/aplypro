# frozen_string_literal: true

class CreateASPRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :asp_requests do |t|
      t.timestamp :sent_at

      t.timestamps
    end
  end
end
