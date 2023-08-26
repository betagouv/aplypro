# frozen_string_literal: true

class Schooling < ApplicationRecord
  belongs_to :student
  belongs_to :classe

  has_many :pfmps, dependent: :destroy
end
