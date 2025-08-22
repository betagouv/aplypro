# frozen_string_literal: true

module UserAuthorisation
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    def current_role
      return if selected_establishment.blank?

      establishment_user_roles.find_by({ establishment_id: selected_establishment.id })
    end

    def confirmed_director?
      selected_establishment.confirmed_director == self
    end

    def director?
      current_role&.dir?
    end

    def can_invite?
      director?
    end

    def cannot_invite?
      !can_invite?
    end

    def can_validate?
      director?
    end

    def can_abrogate?
      director?
    end

    def can_retry_payment?
      director?
    end

    def cannot_validate?
      !can_validate?
    end

    def can_try_to_generate_attributive_decisions?
      director?
    end
  end
  # rubocop:enable Metrics/BlockLength
end
