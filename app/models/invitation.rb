# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :establishment, optional: true

  validates :email, presence: true
  normalizes :email, with: ->(email) { email.strip.downcase }
end
