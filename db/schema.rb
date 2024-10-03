# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_09_25_092548) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "asp_payment_request_transitions", force: :cascade do |t|
    t.string "to_state", null: false
    t.text "metadata", default: "{}"
    t.integer "sort_key", null: false
    t.integer "asp_payment_request_id", null: false
    t.boolean "most_recent", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asp_payment_request_id", "most_recent"], name: "index_asp_payment_request_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["asp_payment_request_id", "sort_key"], name: "index_asp_payment_request_transitions_parent_sort", unique: true
  end

  create_table "asp_payment_requests", force: :cascade do |t|
    t.bigint "asp_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "pfmp_id", null: false
    t.bigint "asp_payment_return_id"
    t.bigint "rib_id"
    t.index ["asp_payment_return_id"], name: "index_asp_payment_requests_on_asp_payment_return_id"
    t.index ["asp_request_id"], name: "index_asp_payment_requests_on_asp_request_id"
    t.index ["pfmp_id"], name: "index_asp_payment_requests_on_pfmp_id"
    t.index ["rib_id"], name: "index_asp_payment_requests_on_rib_id"
  end

  create_table "asp_payment_returns", force: :cascade do |t|
    t.string "filename", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filename"], name: "index_asp_payment_returns_on_filename", unique: true
  end

  create_table "asp_requests", force: :cascade do |t|
    t.datetime "sent_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asp_users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_asp_users_on_uid", unique: true
  end

  create_table "classes", force: :cascade do |t|
    t.bigint "establishment_id"
    t.bigint "mef_id", null: false
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_year_id", null: false
    t.index ["establishment_id"], name: "index_classes_on_establishment_id"
    t.index ["mef_id"], name: "index_classes_on_mef_id"
    t.index ["school_year_id"], name: "index_classes_on_school_year_id"
  end

  create_table "establishment_user_roles", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.bigint "user_id", null: false
    t.bigint "granted_by_id"
    t.integer "role", null: false
    t.index ["establishment_id", "user_id"], name: "index_establishment_user_roles_on_establishment_id_and_user_id", unique: true
    t.index ["establishment_id"], name: "index_establishment_user_roles_on_establishment_id"
    t.index ["granted_by_id"], name: "index_establishment_user_roles_on_granted_by_id"
    t.index ["user_id"], name: "index_establishment_user_roles_on_user_id"
  end

  create_table "establishments", force: :cascade do |t|
    t.string "uai", null: false
    t.string "name"
    t.string "denomination"
    t.string "nature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "postal_code"
    t.string "city"
    t.string "telephone"
    t.string "email"
    t.boolean "fetching_students", default: false, null: false
    t.string "address_line1"
    t.string "address_line2"
    t.string "private_contract_type_code"
    t.string "academy_code"
    t.string "academy_label"
    t.string "students_provider"
    t.string "ministry"
    t.bigint "confirmed_director_id"
    t.string "department_code"
    t.string "commune_code"
    t.index ["confirmed_director_id"], name: "index_establishments_on_confirmed_director_id"
    t.index ["uai"], name: "index_establishments_on_uai", unique: true
  end

  create_table "exclusions", force: :cascade do |t|
    t.string "uai", null: false
    t.string "mef_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uai", "mef_code"], name: "index_exclusions_on_uai_and_mef_code", unique: true
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "establishment_id", null: false
    t.bigint "user_id", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["establishment_id", "email"], name: "index_invitations_on_establishment_id_and_email", unique: true
    t.index ["establishment_id"], name: "index_invitations_on_establishment_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "mefs", force: :cascade do |t|
    t.string "code", null: false
    t.string "label", null: false
    t.string "short", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mefstat11", null: false
    t.integer "ministry", null: false
    t.bigint "school_year_id"
    t.index ["code"], name: "index_mefs_on_code", unique: true
    t.index ["mefstat11"], name: "index_mefs_on_mefstat11"
    t.index ["school_year_id"], name: "index_mefs_on_school_year_id"
  end

  create_table "pfmp_transitions", force: :cascade do |t|
    t.string "to_state", null: false
    t.text "metadata", default: "{}"
    t.integer "sort_key", null: false
    t.integer "pfmp_id", null: false
    t.boolean "most_recent", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pfmp_id", "most_recent"], name: "index_pfmp_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["pfmp_id", "sort_key"], name: "index_pfmp_transitions_parent_sort", unique: true
  end

  create_table "pfmps", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "day_count"
    t.bigint "schooling_id", null: false
    t.string "asp_prestation_dossier_id"
    t.integer "amount"
    t.string "administrative_number"
    t.index ["asp_prestation_dossier_id"], name: "index_pfmps_on_asp_prestation_dossier_id", unique: true
    t.index ["schooling_id"], name: "index_pfmps_on_schooling_id"
  end

  create_table "ribs", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.string "iban"
    t.string "bic"
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.integer "owner_type", default: 1, null: false
    t.bigint "establishment_id"
    t.index ["establishment_id"], name: "index_ribs_on_establishment_id"
    t.index ["student_id", "establishment_id"], name: "one_active_rib_per_student_per_establishment", unique: true, where: "(archived_at IS NULL)"
    t.index ["student_id"], name: "index_ribs_on_student_id"
  end

  create_table "school_years", force: :cascade do |t|
    t.integer "start_year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["start_year"], name: "index_school_years_on_start_year", unique: true
  end

  create_table "schoolings", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "classe_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "attributive_decision_version", default: 0
    t.boolean "generating_attributive_decision", default: false, null: false
    t.string "asp_dossier_id"
    t.string "administrative_number"
    t.integer "status"
    t.integer "abrogation_decision_version", default: 0
    t.date "extended_end_date"
    t.index ["administrative_number"], name: "index_schoolings_on_administrative_number", unique: true
    t.index ["asp_dossier_id"], name: "index_schoolings_on_asp_dossier_id", unique: true
    t.index ["classe_id"], name: "index_schoolings_on_classe_id"
    t.index ["student_id", "classe_id"], name: "one_schooling_per_class_student", unique: true
    t.index ["student_id"], name: "index_schoolings_on_student_id"
    t.index ["student_id"], name: "one_active_schooling_per_student", unique: true, where: "(end_date IS NULL)"
  end

  create_table "students", force: :cascade do |t|
    t.string "ine", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "birthdate", null: false
    t.string "asp_file_reference", null: false
    t.string "address_line1"
    t.string "address_line2"
    t.string "address_postal_code"
    t.string "address_city_insee_code"
    t.string "address_city"
    t.string "address_country_code"
    t.string "birthplace_city_insee_code"
    t.string "birthplace_country_insee_code"
    t.integer "biological_sex", default: 0
    t.string "asp_individu_id"
    t.boolean "ine_not_found", default: false, null: false
    t.index ["asp_file_reference"], name: "index_students_on_asp_file_reference", unique: true
    t.index ["asp_individu_id"], name: "index_students_on_asp_individu_id", unique: true
    t.index ["ine"], name: "index_students_on_ine", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", null: false
    t.string "provider", null: false
    t.string "name", null: false
    t.string "secret", null: false
    t.string "token", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.bigint "selected_establishment_id"
    t.boolean "welcomed", default: false, null: false
    t.jsonb "oidc_attributes"
    t.index ["email", "provider"], name: "index_users_on_email_and_provider", unique: true
    t.index ["selected_establishment_id"], name: "index_users_on_selected_establishment_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "wages", force: :cascade do |t|
    t.integer "daily_rate", null: false
    t.string "mefstat4", null: false
    t.integer "yearly_cap", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ministry", null: false
    t.jsonb "mef_codes"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "asp_payment_request_transitions", "asp_payment_requests"
  add_foreign_key "asp_payment_requests", "asp_payment_returns"
  add_foreign_key "asp_payment_requests", "asp_requests"
  add_foreign_key "asp_payment_requests", "pfmps"
  add_foreign_key "classes", "mefs"
  add_foreign_key "classes", "school_years"
  add_foreign_key "establishment_user_roles", "establishments"
  add_foreign_key "establishment_user_roles", "users"
  add_foreign_key "establishment_user_roles", "users", column: "granted_by_id"
  add_foreign_key "establishments", "users", column: "confirmed_director_id"
  add_foreign_key "invitations", "establishments"
  add_foreign_key "invitations", "users"
  add_foreign_key "mefs", "school_years"
  add_foreign_key "pfmp_transitions", "pfmps"
  add_foreign_key "pfmps", "schoolings"
  add_foreign_key "ribs", "establishments"
  add_foreign_key "ribs", "students"
  add_foreign_key "schoolings", "classes", column: "classe_id"
  add_foreign_key "schoolings", "students"
  add_foreign_key "users", "establishments", column: "selected_establishment_id"

  create_view "paid_pfmps", materialized: true, sql_definition: <<-SQL
      WITH paid_requests AS (
           SELECT asp_payment_requests.pfmp_id,
              most_recent_asp_payment_request_transition.created_at AS paid_at
             FROM (asp_payment_requests
               JOIN asp_payment_request_transitions most_recent_asp_payment_request_transition ON (((asp_payment_requests.id = most_recent_asp_payment_request_transition.asp_payment_request_id) AND (most_recent_asp_payment_request_transition.most_recent = true))))
            WHERE (((most_recent_asp_payment_request_transition.to_state)::text = 'paid'::text) AND (most_recent_asp_payment_request_transition.to_state IS NOT NULL))
          )
   SELECT pfmps.id,
      pfmps.start_date,
      pfmps.end_date,
      pfmps.created_at,
      pfmps.updated_at,
      pfmps.day_count,
      pfmps.schooling_id,
      pfmps.asp_prestation_dossier_id,
      pfmps.amount,
      schoolings.student_id,
      paid_requests.paid_at
     FROM ((pfmps
       JOIN schoolings ON ((schoolings.id = pfmps.schooling_id)))
       LEFT JOIN paid_requests ON ((paid_requests.pfmp_id = pfmps.id)))
    WHERE (EXTRACT(isoyear FROM pfmps.end_date) = ANY (ARRAY['2023'::numeric, '2024'::numeric]));
  SQL
end
