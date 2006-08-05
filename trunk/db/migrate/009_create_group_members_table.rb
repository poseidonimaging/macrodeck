class CreateGroupMembersTable < ActiveRecord::Migration
  def self.up
	create_table :group_members do |t|
		t.column :groupid,			:string
		t.column :userid,			:string
		t.column :level,			:string # either "user", "moderator", or "administrator" but ENUMs are a nonstandard MySQL feature and portability is key.
		t.column :isbanned,			:boolean
	end
  end

  def self.down
	drop_table :group_members
  end
end
