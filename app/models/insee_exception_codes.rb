# frozen_string_literal: true

class InseeExceptionCodes < ApplicationRecord
  validates :code_type, :entry_code, :exit_code, presence: true
  validates :entry_code, uniqueness: true

  validates :entry_code, :exit_code, length: { maximum: 5 }, allow_blank: true

  class << self
    def transform_insee_code(entry_code, code_type = "address")
      exception_code = InseeExceptionCodes.find_by(entry_code:, code_type:)

      return exception_code.exit_code if exception_code.present?

      entry_code
    end
  end
end
