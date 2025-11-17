# frozen_string_literal: true

module Academic
  module UsersHelper
    def user_role_badges(roles, establishment: nil, user: nil)
      badges = []
      badges << content_tag(:span, "Directeur", class: "fr-badge fr-badge--blue-ecume") if roles.include?("dir")
      if roles.include?("authorised")
        badges << content_tag(:span, "Habilité", class: "fr-badge fr-badge--purple-glycine fr-ml-1w")
      end
      if establishment && user && establishment.confirmed_director_id == user.id
        badges << content_tag(:span, "Confirmé", class: "fr-badge fr-badge--sm fr-badge--success fr-ml-1w")
      end

      safe_join(badges)
    end
  end
end
