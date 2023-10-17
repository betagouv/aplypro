# frozen_string_literal: true

class EstablishmentUserRole < ApplicationRecord
  belongs_to :establishment
  belongs_to :user

  enum role: { dir: 0, authorised: 1 }

  validates :role, presence: true

  validates :user,
            uniqueness: { scope: %i[establishment_id] }
end
