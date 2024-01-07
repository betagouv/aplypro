require "administrate/base_dashboard"

class ClasseDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    active_pfmps: Field::HasMany,
    active_schoolings: Field::HasMany,
    active_students: Field::HasMany,
    attributive_decisions_attachments: Field::HasMany,
    establishment: Field::BelongsTo,
    label: Field::String,
    mef: Field::BelongsTo,
    pfmps: Field::HasMany,
    schoolings: Field::HasMany,
    start_year: Field::String,
    students: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    establishment
    label
    mef
    active_students
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    active_pfmps
    active_schoolings
    establishment
    label
    mef
    pfmps
    start_year
    students
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    active_pfmps
    active_schoolings
    active_students
    attributive_decisions_attachments
    establishment
    label
    mef
    pfmps
    schoolings
    start_year
    students
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how classes are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(classe)
  #   "Classe ##{classe.id}"
  # end
end
