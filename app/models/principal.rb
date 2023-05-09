class Principal < ApplicationRecord
  validates :name, :provider, :token, :secret, :email, presence: true
end
