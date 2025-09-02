# frozen_string_literal: true

class InseeExceptionCodes < ApplicationRecord
  validates :code_type, :entry_code, :exit_code, presence: true
  validates :entry_code, uniqueness: true
  validates :entry_code, :exit_code, length: { is: 5 }

  after_commit -> { self.class.reset_cache! }

  class << self
    def transform_insee_code(entry_code, code_type = "address")
      mapping[[code_type, entry_code]] || entry_code
    end

    def mapping
      Rails.cache.fetch("insee_exception_codes_mapping", expires_in: 3.hours) do
        all.each_with_object({}) do |exception_code, hash|
          hash[[exception_code.code_type, exception_code.entry_code]] = exception_code.exit_code
        end
      end
    end

    def reset_cache!
      Rails.cache.delete("insee_exception_codes_mapping")
    end
  end
end
