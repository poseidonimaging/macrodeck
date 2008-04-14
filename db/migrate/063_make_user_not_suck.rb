class MakeUserNotSuck < ActiveRecord::Migration
  def self.up
	  remove_column	:users, :name
	  remove_column	:users, :authcode
	  remove_column	:users,	:authcookie
	  remove_column	:users,	:authcookie_set_time

	  add_column	:users, :first_name,	:string
	  add_column	:users, :last_name,		:string
	  add_column	:users,	:created_at,	:timestamp
	  add_column	:users,	:updated_at,	:timestamp

	  change_column	:users,	:uuid,			:string, :null => false

	  add_index		:users,	:uuid,			:unique => true
	  add_index		:users,	:username,		:unique => true
	  add_index		:users,	:facebook_uid
	  add_index		:users,	:facebook_session_key
  end

  def self.down
	  remove_column	:users,	:first_name
	  remove_column	:users,	:last_name
	  remove_column :users,	:created_at
	  remove_column :users,	:updated_at

	  add_column	:users,	:name,			:string
	  add_column	:users,	:authcode,		:string
	  add_column	:users,	:authcookie,	:string
	  add_column	:users,	:authcookie_set_time,	:integer

	  remove_index	:users,	:uuid
	  remove_index	:users,	:username
	  remove_index	:users,	:facebook_uid
	  remove_index	:uesrs,	:facebook_session_key
  end
end
