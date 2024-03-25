# frozen_string_literal: true

class User < ApplicationRecord
  include UserAuthorisation

  devise :authenticatable

  validates :uid, :provider, :name, :token, :secret, :email, presence: true
  validates :email, uniqueness: { scope: :provider }
  normalizes :email, with: ->(email) { email.strip.downcase }

  has_many :establishment_user_roles, dependent: :destroy
  has_many :establishments, through: :establishment_user_roles
  has_many :directed_establishments, class_name: "Establishment", inverse_of: :confirmed_director, dependent: :nullify
  has_many :invitations, dependent: :nullify

  belongs_to :selected_establishment, optional: true, class_name: "Establishment"

  validate :current_establishment_is_legitimate

  def current_establishment_is_legitimate
    return if selected_establishment.blank?

    legit = establishments.include?(selected_establishment)

    errors.add(:selected_establishment, "no corresponding roles found") unless legit
  end

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
