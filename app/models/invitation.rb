# frozen_string_literal: true

class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :establishment

  VALID_DOMAINS = %w[
    gouv.fr
    educagri.fr
  ].freeze

  VALID_EMAILS = /\.(#{VALID_DOMAINS.map { |d| Regexp.escape(d) }.join('|')})\Z/

  validates :email,
            presence: true, format: { with: VALID_EMAILS },
            uniqueness: { scope: :establishment_id }
end
