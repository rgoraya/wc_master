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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120204012035) do

  create_table "feed_backs", :force => true do |t|
    t.string   "subject"
    t.string   "description"
    t.string   "email"
    t.integer  "user_id"
    t.integer  "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "wiki_url"
    t.string   "short_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.integer  "user_id"
  end

  create_table "mapvisualizations", :force => true do |t|
    t.string   "name"
    t.integer  "node_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "references", :force => true do |t|
    t.integer  "relationship_id"
    t.string   "reference_content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "cause_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "relationship_type"
    t.integer  "references_count",  :default => 0
    t.integer  "user_id"
  end

  add_index "relationships", ["cause_id"], :name => "index_relationships_on_cause_id"
  add_index "relationships", ["issue_id"], :name => "index_relationships_on_issue_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "suggestions", :force => true do |t|
    t.string   "title"
    t.string   "wiki_url"
    t.string   "causality"
    t.string   "status"
    t.integer  "issue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reputation",        :default => 1
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",     :null => false
    t.integer  "item_id",       :null => false
    t.string   "event",         :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "reverted_from"
  end

  add_index "versions", ["event"], :name => "index_versions_on_event"
  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"
  add_index "versions", ["whodunnit"], :name => "index_versions_on_whodunnit"

end
