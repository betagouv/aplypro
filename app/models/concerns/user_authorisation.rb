# frozen_string_literal: true

module UserAuthorisation
  extend ActiveSupport::Concern

  included do
    def current_role
      establishment_users.find_by({ establishment_id: establishment.id })
    end

    def director?
      current_role.dir?
    end

    def can_authorise?
      director?
    end

    def can_validate?
      director?
    end
  end
end
