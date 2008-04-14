class CreateDataObjects < ActiveRecord::Migration
  def self.up
    create_table :data_objects do |t|
		# Foreign Keys
		t.column	:parent_id,			:integer
		t.column	:category_id,		:integer
		t.column	:application_id,	:integer
		t.column	:created_by_id,		:integer, :null => false, :default => 0
		t.column	:updated_by_id,		:integer, :null => false, :default => 0
		t.column	:owned_by_id,		:integer, :null => false, :default => 0
		# Single Table Inheritance
		t.column	:type,				:string, :null => false	# Replaces data_type UUID (goes by class name)
		# Creation/Updated
		t.column	:created_at,		:timestamp, :null => false
		t.column	:updated_at,		:timestamp, :null => false
		# Data
		t.column	:uuid,				:string, :null => false
		t.column	:title,				:string
		t.column	:description,		:text
		t.column	:data,				:text	# Used to be "stringdata" (merging with integerdata)
		t.column	:extended_data,		:text	# Used to be "objectdata"
		# Syndicated remote data - these items are pulled from remote.
		t.column	:is_remote_data,	:bool, :null => false, :default => false
		t.column	:data_source_id,	:integer	# FK
		# URL support
		t.column	:url_part,			:string
    end

	# Indexes
	add_index :data_objects, :uuid, :unique => true
	add_index :data_objects, :url_part
  end

  def self.down
    drop_table :data_objects
  end
end
