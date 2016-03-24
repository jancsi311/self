# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160314171331) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "events", force: :cascade do |t|
    t.text     "description"
    t.integer  "hours",                                default: 0,            null: false
    t.integer  "minutes",                              default: 0,            null: false
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.date     "worked_at",                            default: '2015-11-14', null: false
    t.integer  "user_id"
    t.integer  "project_id"
    t.decimal  "amount",      precision: 14, scale: 6, default: "0.0"
    t.boolean  "ot",                                   default: false
    t.boolean  "gefroren",                             default: false
    t.string   "status",                               default: "submitted",  null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text     "comment"
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "status",     default: "pending"
  end

  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "slug",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "projects", ["name"], name: "index_projects_on_name", using: :btree
  add_index "projects", ["slug"], name: "index_projects_on_slug", using: :btree

  create_table "rates", force: :cascade do |t|
    t.decimal  "hourly_rate",     precision: 12, scale: 4
    t.decimal  "hourly_rate_ot",  precision: 12, scale: 4
    t.integer  "payable_id"
    t.string   "payable_type"
    t.date     "available_from"
    t.date     "available_until"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rates", ["payable_id"], name: "index_rates_on_payable_id", using: :btree

  create_table "user_projects", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_projects", ["project_id"], name: "index_user_projects_on_project_id", using: :btree
  add_index "user_projects", ["user_id", "project_id"], name: "index_user_projects_on_user_id_and_project_id", unique: true, using: :btree
  add_index "user_projects", ["user_id"], name: "index_user_projects_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: "",    null: false
    t.string   "encrypted_password",  default: "",    null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "first_name",          default: "N/A", null: false
    t.string   "last_name",           default: "N/A", null: false
    t.boolean  "admin",               default: false, null: false
    t.integer  "vacation_limit",      default: 10,    null: false
    t.string   "profile_picture"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "vacation_limits", force: :cascade do |t|
    t.integer  "year",       null: false
    t.integer  "limit",      null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "vacation_limits", ["user_id", "year"], name: "index_vacation_limits_on_user_id_and_year", unique: true, using: :btree
  add_index "vacation_limits", ["user_id"], name: "index_vacation_limits_on_user_id", using: :btree

  create_table "vacation_requests", force: :cascade do |t|
    t.date     "vacation_from",                null: false
    t.date     "vacation_to",                  null: false
    t.integer  "user_id"
    t.integer  "status",        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length",        default: 0
    t.boolean  "paid",          default: true
    t.text     "reason",                       null: false
    t.integer  "admin_id"
  end

end
