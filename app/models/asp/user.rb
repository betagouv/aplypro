# frozen_string_literal: true

module ASP
  class User < ApplicationRecord
    EMAIL_DOMAIN = "asp-public.fr"

    devise :authenticatable

    validates :uid, :provider, :name, :email, presence: true

    validates :email, format: { with: /@#{EMAIL_DOMAIN}\z/ }

    class << self
      def from_oidc(attrs)
        User.find_or_initialize_by(uid: attrs["uid"], provider: attrs["provider"]).tap do |user|
          user.name = attrs["info"]["name"]
          user.email = attrs["info"]["email"]
        end
      end
    end

    def to_s
      name
    end
  end
end
