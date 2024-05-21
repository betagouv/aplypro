# frozen_string_literal: true

class CreatePaidPfmps < ActiveRecord::Migration[7.1]
  def change
    create_view :paid_pfmps, materialized: true
  end
end
