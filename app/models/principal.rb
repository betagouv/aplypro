# frozen_string_literal: true

class Principal < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[developer fim]

  validates :uid, :provider, :name, :token, :secret, :email, presence: true

  belongs_to :establishment

  class << self
    # ideally all these methods would live in some OIDC-factory but I
    # can't figure out a pattern I like quite yet
    def from_oidc(attrs)
      # we can't use find_or_create because a bunch of fields are mandatory
      principal = Principal.find_or_initialize_by(uid: attrs["uid"], provider: attrs["provider"])

      principal.token = attrs["credentials"]["token"]
      principal.secret = "nope"
      principal.name = attrs["info"]["name"]
      principal.email = attrs["info"]["email"]

      principal
    end

    def from_fim(attrs)
      principal = from_oidc(attrs)

      mapper = IdentityMappers::Fim.new(attrs["extra"]["raw_info"])

      principal.establishment_id = mapper.uai

      principal
    end

    def from_developer(attrs)
      principal = from_oidc(oidcize_dev_hash(attrs))

      principal.establishment_id = attrs["info"]["uai"]

      principal
    end

    private

    # makes the developer auth hash OIDC like
    def oidcize_dev_hash(attrs)
      attrs.merge(
        {
          "credentials" => {
            "token" => "dev token"
          },
          "info" => {
            "name" => attrs["uid"],
            "email" => attrs["uid"]
          }
        }
      )
    end
  end

  def to_s
    name
  end
end
