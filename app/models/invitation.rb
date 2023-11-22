# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :establishment

  validates :email,
            presence: true,
            uniqueness: { scope: :establishment_id }
  normalizes :email, with: ->(email) { email.strip.downcase }
end
