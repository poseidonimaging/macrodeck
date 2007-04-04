class AddRemoteData < ActiveRecord::Migration
  def self.up
	create_table :data_sources do |t|
		t.column :uuid,				:string
		t.column :type,				:string
		t.column :title,			:string
		t.column :description,		:text
		t.column :uri,				:text
		t.column :creation,			:integer
		t.column :updated,			:integer
		t.column :update_interval,	:integer # the number of seconds between updates
	end
	create_table :user_sources do |t|
		t.column :sourceid,			:string
		t.column :userid,			:string
	end
	# Now some added columns
	add_column :data_items, :remote_data, :boolean
	add_column :data_items, :sourceid, :string
	add_column :data_groups, :remote_data, :boolean
	add_column :data_groups, :sourceid, :string
  end

  def self.down
	remove_table :data_sources
	remove_table :user_sources
	remove_column :data_items, :remote_data
	remove_column :data_items, :sourceid
	remove_column :data_groups, :remote_data
	remove_column :data_groups, :sourceid
  end
end
