# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :establishment

  VALID_DOMAINS = %w[
    gouv.fr
    educagri.fr
    ac-aix-marseille.fr
    ac-amiens.fr
    ac-besancon.fr
    ac-bordeaux.fr
    ac-normandie.fr
    ac-clermont.fr
    ac-corse.fr
    ac-creteil.fr
    ac-dijon.fr
    ac-grenoble.fr
    ac-guadeloupe.fr
    ac-guyane.fr
    ac-reunion.fr
    ac-lille.fr
    ac-limoges.fr
    ac-lyon.fr
    ac-martinique.fr
    ac-mayotte.fr
    ac-montpellier.fr
    ac-nancy-metz.fr
    ac-nantes.fr
    ac-nice.fr
    ac-orleans-tours.fr
    ac-paris.fr
    ac-poitiers.fr
    ac-reims.fr
    ac-rennes.fr
    ac-strasbourg.fr
    ac-toulouse.fr
    ac-versailles.fr
  ].freeze

  VALID_EMAILS = /[\.@](#{VALID_DOMAINS.map { |d| Regexp.escape(d) }.join('|')})\Z/

  validates :email,
            presence: true, format: { with: VALID_EMAILS },
            uniqueness: { scope: :establishment_id }
  normalizes :email, with: ->(email) { email.strip.downcase }
end
