# frozen_string_literal: true

class Principal < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[developer fim masa]

  validates :uid, :provider, :name, :token, :secret, :email, presence: true

  belongs_to :establishment, optional: true

  class << self
    # ideally all these methods would live in some OIDC-factory but I
    # can't figure out a pattern I like quite yet
    def from_oidc(attrs)
      # we can't use find_or_create because a bunch of fields are mandatory
      Principal.find_or_initialize_by(uid: attrs["uid"], provider: attrs["provider"]).tap do |principal|
        principal.token = attrs["credentials"]["token"]
        principal.secret = "nope"
        principal.name = attrs["info"]["name"]
        principal.email = attrs["info"]["email"]
      end
    end
  end

  def to_s
    name
  end
end
