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

ActiveRecord::Schema[8.1].define(version: 2026_05_03_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "industry"
    t.string "name", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["tenant_id", "industry"], name: "index_companies_on_tenant_id_and_industry"
    t.index ["tenant_id", "name"], name: "index_companies_on_tenant_id_and_name"
    t.index ["tenant_id"], name: "index_companies_on_tenant_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_contacts_on_company_id"
    t.index ["tenant_id", "company_id"], name: "index_contacts_on_tenant_id_and_company_id"
    t.index ["tenant_id", "email"], name: "index_contacts_on_tenant_id_and_email"
    t.index ["tenant_id", "last_name"], name: "index_contacts_on_tenant_id_and_last_name"
    t.index ["tenant_id"], name: "index_contacts_on_tenant_id"
  end

  create_table "deals", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "closed_at"
    t.bigint "company_id"
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.date "expected_close_date"
    t.string "name", null: false
    t.integer "stage", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["company_id"], name: "index_deals_on_company_id"
    t.index ["contact_id"], name: "index_deals_on_contact_id"
    t.index ["tenant_id", "closed_at"], name: "index_deals_on_tenant_id_and_closed_at"
    t.index ["tenant_id", "company_id"], name: "index_deals_on_tenant_id_and_company_id"
    t.index ["tenant_id", "expected_close_date"], name: "index_deals_on_tenant_id_and_expected_close_date"
    t.index ["tenant_id", "stage", "created_at"], name: "index_deals_on_tenant_id_and_stage_and_created_at"
    t.index ["tenant_id", "stage"], name: "index_deals_on_tenant_id_and_stage"
    t.index ["tenant_id", "user_id"], name: "index_deals_on_tenant_id_and_user_id"
    t.index ["tenant_id"], name: "index_deals_on_tenant_id"
    t.index ["user_id"], name: "index_deals_on_user_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.date "due_date"
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "status"], name: "index_invoices_on_tenant_id_and_status"
    t.index ["tenant_id"], name: "index_invoices_on_tenant_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "notable_id", null: false
    t.string "notable_type", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable"
    t.index ["tenant_id", "notable_type", "notable_id"], name: "index_notes_on_tenant_id_and_notable_type_and_notable_id"
    t.index ["tenant_id", "user_id"], name: "index_notes_on_tenant_id_and_user_id"
    t.index ["tenant_id"], name: "index_notes_on_tenant_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "plan_name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "status"], name: "index_subscriptions_on_tenant_id_and_status"
    t.index ["tenant_id"], name: "index_subscriptions_on_tenant_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.string "context", limit: 128
    t.datetime "created_at"
    t.bigint "tag_id"
    t.bigint "taggable_id"
    t.string "taggable_type"
    t.bigint "tagger_id"
    t.string "tagger_type"
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "taggings_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tenants", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_tenants_on_active"
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "jti", null: false
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 2, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id", "email"], name: "index_users_on_tenant_id_and_email"
    t.index ["tenant_id", "role"], name: "index_users_on_tenant_id_and_role"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "companies", "tenants"
  add_foreign_key "contacts", "companies"
  add_foreign_key "contacts", "tenants"
  add_foreign_key "deals", "companies"
  add_foreign_key "deals", "contacts"
  add_foreign_key "deals", "tenants"
  add_foreign_key "deals", "users"
  add_foreign_key "invoices", "tenants"
  add_foreign_key "notes", "tenants"
  add_foreign_key "notes", "users"
  add_foreign_key "subscriptions", "tenants"
  add_foreign_key "taggings", "tags"
  add_foreign_key "users", "tenants"
end
