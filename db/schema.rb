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

ActiveRecord::Schema.define(version: 20161208091531) do

  create_table "activities", force: :cascade do |t|
    t.string   "public_name"
    t.string   "secret_name"
    t.string   "description"
    t.string   "location"
    t.datetime "start"
    t.datetime "end"
    t.datetime "deadline"
    t.boolean  "show_hidden"
    t.integer  "group_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["group_id"], name: "index_activities_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "group_id"
    t.boolean  "is_leader"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_members_on_group_id"
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
    t.index ["activity_id"], name: "index_participants_on_activity_id"
    t.index ["person_id"], name: "index_participants_on_person_id"
  end

  create_table "people", force: :cascade do |t|
    t.string   "first_name"
    t.string   "infix"
    t.string   "last_name"
    t.date     "birth_date"
    t.string   "email"
    t.boolean  "is_admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "confirmation_token"
    t.string   "password_reset_token"
    t.integer  "person_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["person_id"], name: "index_users_on_person_id"
  end

end
