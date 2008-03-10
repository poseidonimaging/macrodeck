# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 66) do

  create_table "categories", :force => true do |t|
    t.string  "uuid"
    t.string  "title"
    t.text    "description"
    t.string  "url_part"
    t.string  "parent_uuid"
    t.boolean "can_have_items", :default => false, :null => false
  end

  create_table "components", :force => true do |t|
    t.string  "uuid"
    t.string  "descriptive_name"
    t.text    "description"
    t.string  "version"
    t.string  "homepage"
    t.string  "tags"
    t.string  "creator"
    t.string  "owner"
    t.string  "status"
    t.text    "code"
    t.string  "internal_name"
    t.integer "creation",          :default => 0, :null => false
    t.integer "updated",           :default => 0, :null => false
    t.text    "read_permissions"
    t.text    "write_permissions"
  end

  create_table "data_groups", :force => true do |t|
    t.string   "data_type",                                                             :null => false
    t.string   "created_by",        :default => "7b7e7c62-0a56-4785-93d5-6e689c9793c9", :null => false
    t.string   "uuid",                                                                  :null => false
    t.string   "owned_by",          :default => "7b7e7c62-0a56-4785-93d5-6e689c9793c9", :null => false
    t.text     "tags"
    t.string   "parent_uuid"
    t.string   "title"
    t.text     "description"
    t.text     "read_permissions"
    t.text     "write_permissions"
    t.boolean  "remote_data",       :default => false,                                  :null => false
    t.string   "sourceid"
    t.text     "include_sources"
    t.string   "category_uuid"
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.string   "updated_by",        :default => "7b7e7c62-0a56-4785-93d5-6e689c9793c9", :null => false
  end

  create_table "data_items", :force => true do |t|
    t.string   "data_type",                                                             :null => false
    t.string   "application_uuid",  :default => "7b7e7c62-0a56-4785-93d5-6e689c9793c9", :null => false
    t.string   "uuid",                                                                  :null => false
    t.string   "data_group_uuid",                                                       :null => false
    t.string   "owned_by",          :default => "7b7e7c62-0a56-4785-93d5-6e689c9793c9", :null => false
    t.string   "created_by",        :default => "7b7e7c62-0a56-4785-93d5-6e689c9793c9", :null => false
    t.text     "tags"
    t.string   "title"
    t.text     "description"
    t.text     "stringdata"
    t.integer  "integerdata"
    t.text     "objectdata"
    t.text     "read_permissions"
    t.text     "write_permissions"
    t.boolean  "remote_data",       :default => false,                                  :null => false
    t.string   "sourceid"
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.string   "updated_by",        :default => "7b7e7c62-0a56-4785-93d5-6e689c9793c9", :null => false
  end

  create_table "data_objects", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "category_id"
    t.integer  "application_id"
    t.integer  "created_by_id",  :default => 0,     :null => false
    t.integer  "updated_by_id",  :default => 0,     :null => false
    t.integer  "owned_by_id",    :default => 0,     :null => false
    t.string   "type",                              :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "uuid",                              :null => false
    t.string   "title"
    t.text     "description"
    t.text     "data"
    t.text     "extended_data"
    t.boolean  "is_remote_data", :default => false, :null => false
    t.integer  "data_source_id"
    t.string   "url_part"
  end

  add_index "data_objects", ["uuid"], :name => "index_data_objects_on_uuid", :unique => true
  add_index "data_objects", ["url_part"], :name => "index_data_objects_on_url_part"

  create_table "data_sources", :force => true do |t|
    t.string  "uuid"
    t.string  "data_type"
    t.string  "title"
    t.text    "description"
    t.text    "uri"
    t.integer "creation",        :default => 0, :null => false
    t.integer "updated",         :default => 0, :null => false
    t.integer "update_interval", :default => 0, :null => false
    t.string  "file_type"
  end

  create_table "environments", :force => true do |t|
    t.string  "uuid"
    t.string  "short_name"
    t.string  "title"
    t.text    "description"
    t.string  "creator"
    t.string  "owner"
    t.integer "creation"
    t.text    "read_permissions"
    t.text    "write_permissions"
    t.string  "layout_type"
  end

  create_table "group_members", :force => true do |t|
    t.string  "groupid"
    t.string  "userid"
    t.string  "level"
    t.boolean "isbanned", :null => false
  end

  create_table "groups", :force => true do |t|
    t.string  "uuid"
    t.string  "name"
    t.string  "displayname"
    t.integer "creation"
    t.text    "description"
  end

  create_table "quotas", :force => true do |t|
    t.string "storageid"
    t.string "objectid"
    t.string "max_file_size"
    t.string "max_total_size"
  end

  create_table "relationships", :force => true do |t|
    t.string   "source_uuid",  :null => false
    t.string   "target_uuid",  :null => false
    t.string   "relationship", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "storages", :force => true do |t|
    t.string  "objectid"
    t.string  "objecttype"
    t.binary  "data"
    t.string  "parent"
    t.string  "title"
    t.string  "creator"
    t.string  "creatorapp"
    t.string  "owner"
    t.text    "tags"
    t.text    "description"
    t.text    "read_permissions"
    t.text    "write_permissions"
    t.integer "updated"
  end

  create_table "subscription_payments", :force => true do |t|
    t.string  "uuid"
    t.string  "user_uuid"
    t.string  "subscription_uuid"
    t.float   "amount_paid"
    t.integer "date_paid"
  end

  create_table "subscription_services", :force => true do |t|
    t.string  "uuid"
    t.string  "subscription_type"
    t.string  "provider_uuid"
    t.string  "title"
    t.text    "description"
    t.string  "creator"
    t.integer "creation"
    t.integer "updated"
    t.float   "amount"
    t.integer "recurrence"
    t.integer "recurrence_day"
    t.integer "recurrence_notify"
    t.text    "notify_template"
  end

  create_table "subscriptions", :force => true do |t|
    t.string  "uuid"
    t.string  "user_uuid"
    t.string  "sub_service_uuid"
    t.string  "billing_data"
    t.integer "creation"
    t.integer "updated"
    t.integer "status"
  end

  create_table "user_sources", :force => true do |t|
    t.string "sourceid"
    t.string "userid"
  end

  create_table "users", :force => true do |t|
    t.string   "uuid",                 :null => false
    t.string   "username"
    t.string   "password"
    t.string   "secretquestion"
    t.string   "secretanswer"
    t.string   "displayname"
    t.boolean  "verified_email"
    t.string   "email"
    t.string   "facebook_session_key"
    t.string   "facebook_uid"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["uuid"], :name => "index_users_on_uuid", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true
  add_index "users", ["facebook_uid"], :name => "index_users_on_facebook_uid"
  add_index "users", ["facebook_session_key"], :name => "index_users_on_facebook_session_key"

  create_table "widget_instances", :force => true do |t|
    t.string  "instanceid"
    t.string  "widgetid"
    t.string  "parent"
    t.text    "configuration"
    t.integer "position"
    t.integer "order"
  end

  create_table "widgets", :force => true do |t|
    t.string  "uuid"
    t.string  "descriptive_name"
    t.text    "description"
    t.string  "version"
    t.string  "homepage"
    t.string  "tags"
    t.string  "creator"
    t.string  "owner"
    t.string  "status"
    t.text    "required_components"
    t.text    "code"
    t.text    "configuration_fields"
    t.string  "internal_name"
    t.text    "read_permissions"
    t.text    "write_permissions"
    t.integer "creation",             :default => 0, :null => false
    t.integer "updated",              :default => 0, :null => false
  end

end
