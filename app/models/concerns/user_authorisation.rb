# frozen_string_literal: true

module UserAuthorisation
  extend ActiveSupport::Concern

  included do
    def current_role
      establishment_user_roles.find_by({ establishment_id: establishment.id })
    end

    def director?
      current_role.dir?
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

    def can_generate_attributive_decisions?
      director?
    end
  end
end
