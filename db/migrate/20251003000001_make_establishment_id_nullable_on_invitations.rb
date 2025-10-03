# frozen_string_literal: true

class MakeEstablishmentIdNullableOnInvitations < ActiveRecord::Migration[7.2]
  def change
    change_column_null :invitations, :establishment_id, true
  end
end
