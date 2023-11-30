# frozen_string_literal: true

class User < ApplicationRecord
  include UserAuthorisation

  if Rails.env.production?
    devise :omniauthable, omniauth_providers: %i[fim masa]
  else
    devise :omniauthable, omniauth_providers: %i[fim masa developer]
  end

  validates :uid, :provider, :name, :token, :secret, :email, presence: true
  validates :email, uniqueness: { scope: :provider }
  normalizes :email, with: ->(email) { email.strip.downcase }

  has_many :establishment_user_roles, dependent: :destroy
  has_many :establishments, through: :establishment_user_roles
  has_many :invitations, dependent: :nullify

  belongs_to :establishment, optional: true

  class << self
    # ideally all these methods would live in some OIDC-factory but I
    # can't figure out a pattern I like quite yet
    def from_oidc(attrs)
      # we can't use find_or_create because a bunch of fields are mandatory
      User.find_or_initialize_by(uid: attrs["uid"], provider: attrs["provider"]).tap do |user|
        user.token = attrs["credentials"]["token"]
        user.secret = "nope"
        user.name = attrs["info"]["name"]
        user.email = attrs["info"]["email"]
        user.oidc_attributes = attrs
      end
    end
  end

  def to_s
    name
  end
end
