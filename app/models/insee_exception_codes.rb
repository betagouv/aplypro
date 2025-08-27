# frozen_string_literal: true

class InseeExceptionCodes < ApplicationRecord
  validates :code_type, :entry_code, :exit_code, presence: true
  validates :entry_code, unique: true
end
