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

ActiveRecord::Schema.define(version: 2018_07_06_115359) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "deployments", force: :cascade do |t|
    t.integer "user_id"
    t.string "commit_id"
    t.integer "reviewer_id"
    t.text "checklist"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "project_name"
    t.string "diff_link"
    t.string "job_name"
    t.integer "project_id"
    t.integer "review_time"
    t.string "jira_link"
    t.string "checklist_comment"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "gitlab_token"
    t.string "username", null: false
    t.integer "gitlab_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jira_token"
    t.boolean "admin", default: false
  end

end
