class CreateASPAdresseCorrectionRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :asp_adresse_correction_requests do |t|
      t.timestamp :sent_at
      t.timestamps
    end
  end
end
