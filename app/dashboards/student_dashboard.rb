require "administrate/base_dashboard"
require_relative "../fields/da_link_field"

class StudentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    address_city: Field::String,
    address_city_insee_code: Field::String,
    address_country_code: Field::String,
    address_line1: Field::String,
    address_line2: Field::String,
    address_postal_code: Field::String,
    asp_file_reference: DaLinkField.with_options(
      searchable: true,
    ),
    birthdate: Field::Date,
    classe: Field::HasOne,
    classes: Field::HasMany,
    current_schooling: Field::HasOne,
    establishment: Field::HasOne,
    first_name: Field::String,
    ine: Field::String,
    last_name: Field::String,
    payments: Field::HasMany,
    pfmps: Field::HasMany,
    rib: Field::HasOne,
    ribs: Field::HasMany,
    schoolings: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    first_name
    last_name
    asp_file_reference
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :address_city,
    :address_city_insee_code,
    :address_country_code,
    :address_line1,
    :address_line2,
    :address_postal_code,
    :asp_file_reference,
    :birthdate,
    # :classe,
    # :classes,
    # :current_schooling,
    # :establishment,
    # :first_name,
    # :ine,
    # :last_name,
    # :payments,
    # :pfmps,
    :rib,
    #:schoolings,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    address_city
    address_city_insee_code
    address_country_code
    address_line1
    address_line2
    address_postal_code
    asp_file_reference
    birthdate
    classe
    classes
    current_schooling
    establishment
    first_name
    ine
    last_name
    payments
    pfmps
    rib
    ribs
    schoolings
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

  # Overwrite this method to customize how students are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(student)
    student.to_s
  end
end
