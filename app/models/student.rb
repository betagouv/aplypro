# frozen_string_literal: true

class Student < ApplicationRecord
  self.primary_key = "ine"

  validates :ine, :first_name, :last_name, presence: true

  belongs_to :classe

  has_one :establishment, through: :classe

  def to_s
    [first_name, last_name].join
  end
end
