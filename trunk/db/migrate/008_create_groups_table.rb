class CreateGroupsTable < ActiveRecord::Migration
  def self.up
	create_table :groups do |t|
		t.column :uuid,			:string
		t.column :name,			:string
		t.column :displayname,	:string
		t.column :creation,		:integer
	end
  end

  def self.down
	drop_table :groups
  end
end
