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

ActiveRecord::Schema.define(version: 20190203193638) do

  create_table "activities", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "location"
    t.datetime "start"
    t.datetime "end"
    t.datetime "deadline"
    t.integer  "group_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.datetime "reminder_at"
    t.boolean  "reminder_done"
    t.boolean  "subgroup_division_enabled"
    t.boolean  "subgroup_division_done"
    t.boolean  "no_response_action",        default: true
    t.index ["group_id"], name: "index_activities_on_group_id"
  end

  create_table "default_subgroups", force: :cascade do |t|
    t.integer  "group_id"
    t.string   "name",          null: false
    t.boolean  "is_assignable"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["group_id"], name: "index_default_subgroups_on_group_id"
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
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "api_token"
    t.index ["api_token"], name: "index_groups_on_api_token", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "group_id"
    t.boolean  "is_leader"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_members_on_group_id"
    t.index ["person_id", "group_id"], name: "index_members_on_person_id_and_group_id", unique: true
    t.index ["person_id"], name: "index_members_on_person_id"
  end

  create_table "participants", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "activity_id"
    t.boolean  "is_organizer"
    t.boolean  "attending"
    t.text     "notes"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "subgroup_id"
    t.index ["activity_id"], name: "index_participants_on_activity_id"
    t.index ["person_id", "activity_id"], name: "index_participants_on_person_id_and_activity_id", unique: true
    t.index ["person_id"], name: "index_participants_on_person_id"
    t.index ["subgroup_id"], name: "index_participants_on_subgroup_id"
  end

  create_table "people", force: :cascade do |t|
    t.string   "first_name"
    t.string   "infix"
    t.string   "last_name"
    t.string   "email"
    t.boolean  "is_admin"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "send_attendance_reminder", default: true
    t.string   "calendar_token"
    t.index ["calendar_token"], name: "index_people_on_calendar_token", unique: true
    t.index ["email"], name: "index_people_on_email", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "ip"
    t.datetime "expires"
    t.string   "remember_digest"
    t.integer  "user_id"
    t.boolean  "active",          default: true
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subgroups", force: :cascade do |t|
    t.integer  "activity_id"
    t.string   "name",          null: false
    t.boolean  "is_assignable"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["activity_id"], name: "index_subgroups_on_activity_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string   "token"
    t.datetime "expires"
    t.string   "tokentype"
    t.integer  "user_id"
    t.index ["token"], name: "index_tokens_on_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.integer  "person_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "confirmed"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["person_id"], name: "index_users_on_person_id", unique: true
  end

end
