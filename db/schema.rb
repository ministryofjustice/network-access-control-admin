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

ActiveRecord::Schema[7.0].define(version: 2023_03_09_151440) do
  create_table "audits", charset: "utf8", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.json "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at", precision: nil
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "certificates", charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.date "expiry_date"
    t.text "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "filename", null: false
    t.string "category", null: false
    t.text "issuer"
    t.text "serial"
    t.text "extensions"
    t.text "contents"
  end

  create_table "clients", charset: "utf8", force: :cascade do |t|
    t.string "shared_secret", null: false
    t.string "ip_range", null: false
    t.bigint "site_id", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "radsec", null: false
    t.index ["site_id"], name: "index_clients_on_site_id"
  end

  create_table "csv_import_results", charset: "utf8", force: :cascade do |t|
    t.text "import_errors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
  end

  create_table "delayed_jobs", charset: "utf8", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", size: :long, null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "mac_authentication_bypasses", charset: "utf8", force: :cascade do |t|
    t.string "address", null: false
    t.string "name"
    t.text "description"
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "site_id", null: false
    t.index ["address"], name: "index_mac_authentication_bypasses_on_address"
    t.index ["site_id"], name: "index_mac_authentication_bypasses_on_site_id"
  end

  create_table "policies", charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "fallback", default: false, null: false
    t.integer "rule_count", default: 0
    t.bigint "site_count", default: 0
    t.string "action", default: "accept"
  end

  create_table "responses", charset: "utf8", force: :cascade do |t|
    t.string "response_attribute", null: false
    t.text "value", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "mac_authentication_bypass_id"
    t.bigint "policy_id"
    t.index ["mac_authentication_bypass_id"], name: "index_responses_on_mac_authentication_bypass_id"
    t.index ["policy_id"], name: "index_responses_on_policy_id"
  end

  create_table "rules", charset: "utf8", force: :cascade do |t|
    t.string "operator", null: false
    t.text "value", null: false
    t.bigint "policy_id", null: false
    t.string "request_attribute", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["policy_id"], name: "index_rules_on_policy_id"
  end

  create_table "site_policies", charset: "utf8", force: :cascade do |t|
    t.bigint "site_id"
    t.bigint "policy_id"
    t.integer "priority"
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "sites", charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamp "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "tag", null: false
    t.bigint "policy_count", default: 0
    t.index ["name"], name: "index_sites_on_name"
  end

  create_table "upcoming_expiring_certificates", charset: "utf8", force: :cascade do |t|
    t.date "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.boolean "editor", default: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "clients", "sites"
  add_foreign_key "mac_authentication_bypasses", "sites"
  add_foreign_key "responses", "mac_authentication_bypasses"
  add_foreign_key "responses", "policies"
  add_foreign_key "rules", "policies"
end
