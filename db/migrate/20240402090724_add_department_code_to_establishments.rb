# frozen_string_literal: true

class AddDepartmentCodeToEstablishments < ActiveRecord::Migration[7.1]
  def change
    add_column :establishments, :department_code, :string
  end
end
