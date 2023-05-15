# frozen_string_literal: true

class Principal < ApplicationRecord
  self.primary_key = %i[uid provider]

  devise :omniauthable, omniauth_providers: %i[developer]

  validates :uid, :provider, :name, :token, :secret, :email, presence: true

  def self.from_omniauth(attrs)
    Principal.find_or_initialize_by(uid: attrs["uid"], provider: attrs["provider"]) do |p|
      p.token = attrs["credentials"]["token"]
      p.secret = attrs["credentials"]["secret"]
      p.email = attrs["info"]["email"]
      p.name = attrs["info"]["name"]
    end
  end
end
