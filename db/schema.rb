# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 46) do

  create_table "components", :force => true do |t|
    t.column "uuid",              :string
    t.column "descriptive_name",  :string
    t.column "description",       :text
    t.column "version",           :string
    t.column "homepage",          :string
    t.column "tags",              :string
    t.column "creator",           :string
    t.column "owner",             :string
    t.column "status",            :string
    t.column "code",              :text
    t.column "internal_name",     :string
    t.column "creation",          :integer, :default => 0, :null => false
    t.column "updated",           :integer, :default => 0, :null => false
    t.column "read_permissions",  :text
    t.column "write_permissions", :text
  end

  create_table "data_groups", :force => true do |t|
    t.column "groupingtype",      :string
    t.column "creator",           :string
    t.column "groupingid",        :string
    t.column "owner",             :string
    t.column "tags",              :text
    t.column "parent",            :string
    t.column "title",             :string
    t.column "description",       :text
    t.column "read_permissions",  :text
    t.column "write_permissions", :text
    t.column "remote_data",       :boolean, :default => false, :null => false
    t.column "sourceid",          :string
    t.column "include_sources",   :text
    t.column "updated",           :integer
    t.column "creation",          :integer
  end

  create_table "data_items", :force => true do |t|
    t.column "datatype",          :string
    t.column "datacreator",       :string
    t.column "dataid",            :string
    t.column "grouping",          :string
    t.column "owner",             :string
    t.column "creator",           :string
    t.column "creation",          :integer
    t.column "tags",              :text
    t.column "title",             :string
    t.column "description",       :text
    t.column "stringdata",        :text
    t.column "integerdata",       :integer
    t.column "objectdata",        :text
    t.column "read_permissions",  :text
    t.column "write_permissions", :text
    t.column "remote_data",       :boolean, :default => false, :null => false
    t.column "sourceid",          :string
    t.column "updated",           :integer
  end

  create_table "data_sources", :force => true do |t|
    t.column "uuid",            :string
    t.column "data_type",       :string
    t.column "title",           :string
    t.column "description",     :text
    t.column "uri",             :text
    t.column "creation",        :integer, :default => 0, :null => false
    t.column "updated",         :integer, :default => 0, :null => false
    t.column "update_interval", :integer, :default => 0, :null => false
    t.column "file_type",       :string
  end

  create_table "environments", :force => true do |t|
    t.column "uuid",              :string
    t.column "short_name",        :string
    t.column "title",             :string
    t.column "description",       :text
    t.column "creator",           :string
    t.column "owner",             :string
    t.column "creation",          :integer
    t.column "read_permissions",  :text
    t.column "write_permissions", :text
    t.column "layout_type",       :string
  end

  create_table "group_members", :force => true do |t|
    t.column "groupid",  :string
    t.column "userid",   :string
    t.column "level",    :string
    t.column "isbanned", :boolean, :default => false, :null => false
  end

  create_table "groups", :force => true do |t|
    t.column "uuid",        :string
    t.column "name",        :string
    t.column "displayname", :string
    t.column "creation",    :integer
    t.column "description", :text
  end

  create_table "quotas", :force => true do |t|
    t.column "storageid",      :string
    t.column "objectid",       :string
    t.column "max_file_size",  :string
    t.column "max_total_size", :string
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "storages", :force => true do |t|
    t.column "objectid",          :string
    t.column "objecttype",        :string
    t.column "data",              :binary
    t.column "parent",            :string
    t.column "title",             :string
    t.column "creator",           :string
    t.column "creatorapp",        :string
    t.column "owner",             :string
    t.column "tags",              :text
    t.column "description",       :text
    t.column "read_permissions",  :text
    t.column "write_permissions", :text
    t.column "updated",           :integer
  end

  create_table "subscription_payments", :force => true do |t|
    t.column "uuid",              :string
    t.column "user_uuid",         :string
    t.column "subscription_uuid", :string
    t.column "amount_paid",       :float
    t.column "date_paid",         :integer
  end

  create_table "subscription_services", :force => true do |t|
    t.column "uuid",              :string
    t.column "subscription_type", :string
    t.column "provider_uuid",     :string
    t.column "title",             :string
    t.column "description",       :text
    t.column "creator",           :string
    t.column "creation",          :integer
    t.column "updated",           :integer
    t.column "amount",            :float
    t.column "recurrence",        :integer
    t.column "recurrence_day",    :integer
    t.column "recurrence_notify", :integer
    t.column "notify_template",   :text
  end

  create_table "subscriptions", :force => true do |t|
    t.column "uuid",             :string
    t.column "user_uuid",        :string
    t.column "sub_service_uuid", :string
    t.column "billing_data",     :string
    t.column "creation",         :integer
    t.column "updated",          :integer
    t.column "status",           :integer
  end

  create_table "user_sources", :force => true do |t|
    t.column "sourceid", :string
    t.column "userid",   :string
  end

  create_table "users", :force => true do |t|
    t.column "uuid",                 :string
    t.column "username",             :string
    t.column "password",             :string
    t.column "secretquestion",       :string
    t.column "secretanswer",         :string
    t.column "name",                 :string
    t.column "displayname",          :string
    t.column "creation",             :integer
    t.column "authcode",             :string
    t.column "verified_email",       :boolean
    t.column "email",                :string
    t.column "authcookie",           :string
    t.column "authcookie_set_time",  :integer
    t.column "facebook_session_key", :string
    t.column "facebook_uid",         :integer
  end

  create_table "widget_instances", :force => true do |t|
    t.column "instanceid",    :string
    t.column "widgetid",      :string
    t.column "parent",        :string
    t.column "configuration", :text
    t.column "position",      :integer
    t.column "order",         :integer
  end

  create_table "widgets", :force => true do |t|
    t.column "uuid",                 :string
    t.column "descriptive_name",     :string
    t.column "description",          :text
    t.column "version",              :string
    t.column "homepage",             :string
    t.column "tags",                 :string
    t.column "creator",              :string
    t.column "owner",                :string
    t.column "status",               :string
    t.column "required_components",  :text
    t.column "code",                 :text
    t.column "configuration_fields", :text
    t.column "internal_name",        :string
    t.column "read_permissions",     :text
    t.column "write_permissions",    :text
    t.column "creation",             :integer, :default => 0, :null => false
    t.column "updated",              :integer, :default => 0, :null => false
  end

end
