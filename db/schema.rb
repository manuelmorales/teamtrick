# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081219104931) do

  create_table "commitments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "sprint_id"
    t.float    "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "duties", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "project_id", :null => false
    t.integer  "role_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plannings", :force => true do |t|
    t.integer  "story_id"
    t.integer  "sprint_id"
    t.integer  "original_estimation"
    t.boolean  "unexpected"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "permalink"
    t.boolean  "unique"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sprints", :force => true do |t|
    t.date     "start_date"
    t.date     "finish_date"
    t.integer  "number_of_workdays"
    t.string   "demo_meeting"
    t.string   "scrum_meeting"
    t.string   "retrospective_meeting"
    t.float    "estimated_focus_factor"
    t.text     "retrospective_report"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "storypoints"
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "importance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "original_estimation"
    t.integer  "hours_left"
    t.integer  "sprint_id"
    t.integer  "story_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks_work_hours", :id => false, :force => true do |t|
    t.integer  "task_id",      :null => false
    t.integer  "work_hour_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "real_name"
    t.boolean  "admin",                                   :default => false
    t.boolean  "disabled",                                :default => false
    t.integer  "available_hours_per_week",                :default => 40
  end

  create_table "work_hours", :force => true do |t|
    t.integer  "hours"
    t.integer  "user_id"
    t.integer  "task_id"
    t.integer  "old_hours_left"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
