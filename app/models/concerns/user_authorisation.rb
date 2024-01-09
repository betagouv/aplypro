# frozen_string_literal: true

module UserAuthorisation
  extend ActiveSupport::Concern

  included do
    def current_role
      return if establishment.blank?

      establishment_user_roles.find_by({ establishment_id: establishment.id })
    end

    def confirmed_director?
      establishment.confirmed_director == self
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

    def cannot_validate?
      !can_validate?
    end

    def can_try_to_generate_attributive_decisions?
      director?
    end

    def can_generate_attributive_decisions?
      confirmed_director?
    end
  end
end
