# frozen_string_literal: true

class EstablishmentUser < ApplicationRecord
  belongs_to :establishment
  belongs_to :user

  enum role: { dir: 0, authorised: 1 }

  validates :role,
            presence: true,
            uniqueness: { scope: %i[establishment_id user_id] }
end
