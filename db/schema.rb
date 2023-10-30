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

ActiveRecord::Schema[7.1].define(version: 2023_10_30_135955) do
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

  create_table "classes", force: :cascade do |t|
    t.bigint "establishment_id"
    t.bigint "mef_id", null: false
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "start_year", null: false
    t.index ["establishment_id"], name: "index_classes_on_establishment_id"
    t.index ["mef_id"], name: "index_classes_on_mef_id"
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
    t.boolean "generating_attributive_decisions", default: false, null: false
    t.string "address_line1"
    t.string "address_line2"
    t.index ["uai"], name: "index_establishments_on_uai", unique: true
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
    t.index ["code"], name: "index_mefs_on_code", unique: true
    t.index ["mefstat11"], name: "index_mefs_on_mefstat11"
  end

  create_table "payment_transitions", force: :cascade do |t|
    t.string "to_state", null: false
    t.text "metadata", default: "{}"
    t.integer "sort_key", null: false
    t.integer "payment_id", null: false
    t.boolean "most_recent", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id", "most_recent"], name: "index_payment_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["payment_id", "sort_key"], name: "index_payment_transitions_parent_sort", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "pfmp_id", null: false
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pfmp_id"], name: "index_payments_on_pfmp_id"
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
    t.boolean "personal", default: false, null: false
    t.index ["student_id"], name: "index_ribs_on_student_id"
  end

  create_table "schoolings", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "classe_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classe_id"], name: "index_schoolings_on_classe_id"
    t.index ["student_id"], name: "index_schoolings_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "ine", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "birthdate", null: false
    t.bigint "current_schooling_id"
    t.index ["current_schooling_id"], name: "index_students_on_current_schooling_id"
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
    t.bigint "establishment_id"
    t.boolean "welcomed", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["establishment_id"], name: "index_users_on_establishment_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "wages", force: :cascade do |t|
    t.integer "daily_rate", null: false
    t.string "mefstat4", null: false
    t.integer "yearly_cap", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "classes", "mefs"
  add_foreign_key "establishment_user_roles", "establishments"
  add_foreign_key "establishment_user_roles", "users"
  add_foreign_key "establishment_user_roles", "users", column: "granted_by_id"
  add_foreign_key "invitations", "establishments"
  add_foreign_key "invitations", "users"
  add_foreign_key "payment_transitions", "payments"
  add_foreign_key "payments", "pfmps"
  add_foreign_key "pfmp_transitions", "pfmps"
  add_foreign_key "pfmps", "schoolings"
  add_foreign_key "ribs", "students"
  add_foreign_key "schoolings", "classes", column: "classe_id"
  add_foreign_key "schoolings", "students"
  add_foreign_key "students", "schoolings", column: "current_schooling_id"
  add_foreign_key "users", "establishments"
end
