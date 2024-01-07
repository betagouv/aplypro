require "administrate/base_dashboard"

class EstablishmentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    academy_code: Field::String,
    academy_label: Field::String,
    address_line1: Field::String,
    address_line2: Field::String,
    city: Field::String,
    classes: Field::HasMany,
    confirmed_director_id: Field::Number,
    denomination: Field::String,
    email: Field::String,
    establishment_user_roles: Field::HasMany,
    fetching_students: Field::Boolean,
    invitations: Field::HasMany,
    ministry: Field::String,
    name: Field::String,
    nature: Field::String,
    postal_code: Field::String,
    private_contract_type_code: Field::String,
    schoolings: Field::HasMany,
    students: Field::HasMany,
    students_provider: Field::String,
    telephone: Field::String,
    uai: Field::String,
    users: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    academy_code
    academy_label
    address_line1
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    academy_code
    academy_label
    address_line1
    address_line2
    city
    classes
    confirmed_director_id
    denomination
    email
    establishment_user_roles
    fetching_students
    invitations
    ministry
    name
    nature
    postal_code
    private_contract_type_code
    schoolings
    students
    students_provider
    telephone
    uai
    users
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    academy_code
    academy_label
    address_line1
    address_line2
    city
    classes
    confirmed_director_id
    denomination
    email
    establishment_user_roles
    fetching_students
    invitations
    ministry
    name
    nature
    postal_code
    private_contract_type_code
    schoolings
    students
    students_provider
    telephone
    uai
    users
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

  # Overwrite this method to customize how establishments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(establishment)
  #   "Establishment ##{establishment.id}"
  # end
end
