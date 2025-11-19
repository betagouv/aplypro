# frozen_string_literal: true

module UserFiltering
  extend ActiveSupport::Concern

  VALID_SORT_OPTIONS = %w[name email last_sign_in].freeze
  USERS_PER_PAGE = 50

  private

  def users_per_page
    USERS_PER_PAGE
  end

  def normalize_search_query
    return nil if params[:search].blank?

    normalized = params[:search].strip.gsub(/[^[:alnum:]\s]/, "").strip
    normalized.presence
  end

  def apply_search(relation)
    query = normalize_search_query
    return relation if query.nil?

    relation.merge(User.search(query))
  end

  def filter_by_role(relation)
    return relation if params[:role].blank?
    return relation unless EstablishmentUserRole.roles.key?(params[:role])

    relation.where(establishment_user_roles: { role: params[:role] })
  end

  def apply_user_sorting(relation, include_uai: false)
    case sort_column(include_uai: include_uai)
    when "uai"
      relation.select("users.*, MIN(establishments.name) as min_establishment_name")
              .group("users.id")
              .order("min_establishment_name ASC, users.name ASC")
    when "email"
      relation.distinct.order("users.email ASC")
    when "last_sign_in"
      relation.distinct.order(Arel.sql("users.last_sign_in_at DESC NULLS LAST"))
    else
      relation.distinct.order("users.name ASC")
    end
  end

  def sort_column(include_uai: false)
    valid_options = include_uai ? VALID_SORT_OPTIONS + ["uai"] : VALID_SORT_OPTIONS
    valid_options.include?(params[:sort]) ? params[:sort] : "name"
  end
end
