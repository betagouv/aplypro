# frozen_string_literal: true

class Principal < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[developer]

  validates :uid, :provider, :name, :token, :secret, :email, presence: true

  belongs_to :establishment

  def self.from_omniauth(attrs)
    Principal.find_or_initialize_by(uid: attrs["uid"], provider: attrs["provider"]) do |p|
      p.attributes.merge(map_auth_hash)
      p.establishment_id = Establishment.find_by(uai: attrs["info"]["uai"])
    end
  end

  private

  AUTH_MAP = {
    token: "credentials.token",
    secret: "credentials.secret",
    email: "info.email",
    name: "info.name"
  }.freeze

  def map_auth_hash(attrs)
    AUTH_MAP.to_h do |k, v|
      path = v.split(".")

      [k => attrs.dig(*path)]
    end
  end
end
