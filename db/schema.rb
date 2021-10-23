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

ActiveRecord::Schema.define(version: 2020_01_10_001440) do

  create_table "arranged_invitations", force: :cascade do |t|
    t.string "account"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_arranged_invitations_on_project_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "task_id"
    t.string "kind"
    t.string "name"
    t.string "original"
    t.string "thumb"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_attachments_on_task_id"
    t.index ["user_id"], name: "index_attachments_on_user_id"
  end

  create_table "checklists", force: :cascade do |t|
    t.text "content"
    t.integer "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "strikeout", default: false
    t.index ["task_id"], name: "index_checklist_on_task_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "task_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_comments_on_task_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contributions", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.integer "task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_contributions_on_project_id"
    t.index ["task_id"], name: "index_contributions_on_task_id"
    t.index ["user_id"], name: "index_contributions_on_user_id"
  end

  create_table "google_accounts", force: :cascade do |t|
    t.string "sub"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_google_accounts_on_user_id"
  end

  create_table "group_members", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_members_on_group_id"
    t.index ["user_id"], name: "index_group_members_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.integer "creator_id"
    t.string "name"
    t.text "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_groups_on_creator_id"
  end

  create_table "histories", force: :cascade do |t|
    t.integer "user_id"
    t.integer "task_id"
    t.integer "kind"
    t.integer "attr"
    t.text "content"
    t.integer "ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_histories_on_task_id"
    t.index ["user_id"], name: "index_histories_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "requestor_id"
    t.integer "accepter_id"
    t.boolean "agreed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepter_id"], name: "index_invitations_on_accepter_id"
    t.index ["requestor_id"], name: "index_invitations_on_requestor_id"
  end

  create_table "kakao_accounts", force: :cascade do |t|
    t.string "account_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_kakao_accounts_on_user_id"
  end

  create_table "naver_accounts", force: :cascade do |t|
    t.string "account_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_naver_accounts_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id"
    t.integer "task_id"
    t.integer "kind"
    t.integer "attr"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "player_id"
    t.index ["player_id"], name: "index_notifications_on_player_id"
    t.index ["task_id"], name: "index_notifications_on_task_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "project_members", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.integer "roletype_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_members_on_project_id"
    t.index ["roletype_id"], name: "index_project_members_on_roletype_id"
    t.index ["user_id"], name: "index_project_members_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.string "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.index ["creator_id"], name: "index_projects_on_creator_id"
  end

  create_table "roletypes", force: :cascade do |t|
    t.string "name"
    t.string "name_kr"
    t.string "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.string "title"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "order"
    t.string "color"
    t.index ["project_id"], name: "index_sections_on_project_id"
  end

  create_table "tags", force: :cascade do |t|
    t.integer "project_id"
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_tags_on_project_id"
  end

  create_table "tags_tasks", id: false, force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "tag_id", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.string "dday"
    t.integer "section_id"
    t.string "checklist_order"
    t.text "history_order"
    t.text "comment_order"
    t.integer "comment_count", default: 0
    t.integer "checklist_count", default: 0
    t.integer "strikeout_count", default: 0
    t.integer "history_count", default: 0
    t.integer "progress", default: 0
    t.string "state"
    t.index ["creator_id"], name: "index_tasks_on_creator_id"
    t.index ["section_id"], name: "index_tasks_on_section_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "account"
    t.string "password"
    t.string "name"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.string "secure_code"
    t.integer "notification_count", default: 0
    t.text "notification_order"
    t.string "state"
    t.index ["account"], name: "index_users_on_account", unique: true
  end

  create_table "watchers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "task_id"
    t.integer "user_id"
    t.index ["task_id"], name: "index_watchers_on_task_id"
    t.index ["user_id"], name: "index_watchers_on_user_id"
  end

  create_table "workers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "task_id"
    t.integer "user_id"
    t.index ["task_id"], name: "index_workers_on_task_id"
    t.index ["user_id"], name: "index_workers_on_user_id"
  end

end
