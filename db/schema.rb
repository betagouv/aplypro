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

ActiveRecord::Schema[7.0].define(version: 2023_06_15_143825) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bank_infos", force: :cascade do |t|
    t.string "iban"
    t.string "bic"
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "student_id", null: false
  end

  create_table "classes", force: :cascade do |t|
    t.bigint "mefstat_id", null: false
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "establishment_id", null: false
    t.index ["mefstat_id"], name: "index_classes_on_mefstat_id"
  end

  create_table "establishments", primary_key: "uai", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "denomination", null: false
    t.string "nature", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "postal_code"
    t.string "city"
    t.index ["uai"], name: "index_establishments_on_uai", unique: true
  end

  create_table "mefstats", force: :cascade do |t|
    t.integer "code", null: false
    t.string "label", null: false
    t.string "short", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_mefstats_on_code", unique: true
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
    t.string "student_id", null: false
  end

  create_table "principals", force: :cascade do |t|
    t.string "uid", null: false
    t.string "provider", null: false
    t.string "name", null: false
    t.string "secret", null: false
    t.string "token", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "establishment_id", null: false
    t.index ["email"], name: "index_principals_on_email", unique: true
    t.index ["uid", "provider"], name: "index_principals_on_uid_and_provider", unique: true
  end

  create_table "ribs", force: :cascade do |t|
    t.string "iban"
    t.string "bic"
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "student_id", null: false
  end

  create_table "students", primary_key: "ine", id: :string, force: :cascade do |t|
    t.bigint "classe_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classe_id"], name: "index_students_on_classe_id"
  end

  add_foreign_key "bank_infos", "students", primary_key: "ine"
  add_foreign_key "classes", "establishments", primary_key: "uai"
  add_foreign_key "classes", "mefstats"
  add_foreign_key "payment_transitions", "payments"
  add_foreign_key "payments", "pfmps"
  add_foreign_key "pfmp_transitions", "pfmps"
  add_foreign_key "pfmps", "students", primary_key: "ine"
  add_foreign_key "principals", "establishments", primary_key: "uai"
  add_foreign_key "ribs", "students", primary_key: "ine"
  add_foreign_key "students", "classes", column: "classe_id"
end
