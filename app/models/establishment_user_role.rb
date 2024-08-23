# frozen_string_literal: true

class EstablishmentUserRole < ApplicationRecord
  belongs_to :establishment
  belongs_to :user

  enum :role, { :dir => 0, :authorised => 1 } # rubocop:disable Style/HashSyntax

  validates :role, presence: true

  validates :user,
            uniqueness: { scope: %i[establishment_id] }

  after_save :revoke_confirmed_director_if_not_director

  def revoke_confirmed_director_if_not_director
    establishment.update(confirmed_director: nil) if role == "authorised" && establishment.confirmed_director == user
  end
end
