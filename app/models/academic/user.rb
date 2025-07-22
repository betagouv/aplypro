# frozen_string_literal: true

module Academic
  class User < User
    devise :authenticatable, :trackable

    validates :uid, :provider, :name, :email, presence: true

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

    def academies
      establishments.distinct.pluck(:academy_code)
    end

    def to_s
      name
    end
  end
end
