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

ActiveRecord::Schema.define(version: 20160710081546) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agent_statuses", force: :cascade do |t|
    t.integer  "agent_id"
    t.string   "team"
    t.string   "status"
    t.boolean  "open"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "closed"
    t.string   "name"
    t.datetime "last_reliable_status"
  end

  create_table "agents", force: :cascade do |t|
    t.integer  "agent_id"
    t.string   "name"
    t.string   "team"
    t.string   "status"
    t.integer  "time_in_status"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "ticket_id"
    t.datetime "arrived_in_queue"
    t.datetime "forwarded_to_agent"
    t.datetime "answered"
    t.datetime "call_ended"
    t.datetime "handling_ended"
    t.string   "direction"
    t.string   "phone_number"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

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

  create_table "queue_items", force: :cascade do |t|
    t.integer  "line"
    t.string   "label"
    t.integer  "time_in_queue"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "team"
    t.boolean  "open"
    t.datetime "closed"
    t.datetime "last_reliable_status"
  end

  create_table "services", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", force: :cascade do |t|
    t.string   "name"
    t.boolean  "filter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.boolean  "filter"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "service_group_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
