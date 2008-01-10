class MakeDataItemsSuckLess < ActiveRecord::Migration
  def self.up
	  # This migration will rename all of the columns to enhance sanity. We also
	  # add a couple NOT NULL restrictions so that errors can't happen anymore.
	  #
	  # It will also add a couple of columns for creation date and migrate the old
	  # UNIX timestamp creations/updateds.
	  say_with_time "Renaming columns..." do
		  rename_column :data_items, :datatype,		:data_type
		  rename_column :data_items, :datacreator,	:application_uuid
		  rename_column :data_items, :dataid,		:uuid
		  rename_column :data_items, :grouping,		:data_group_uuid
		  rename_column :data_items, :owner,		:owned_by
		  rename_column :data_items, :creator,		:created_by
	  end
	  say_with_time "Changing column settings..." do
		  change_column :data_items, :created_by,	:string,	:null => false, :default => CREATOR_MACRODECK
		  change_column :data_items, :owned_by,		:string,	:null => false, :default => CREATOR_MACRODECK
		  change_column :data_items, :data_type,	:string,	:null => false # must have data type
		  change_column :data_items, :application_uuid, :string, :null => false, :default => CREATOR_MACRODECK
		  change_column :data_items, :uuid,			:string,	:null => false # must have UUID
		  change_column :data_items, :data_group_uuid, :string,	:null => false # must belong to a data group
	  end
	  say_with_time "Adding columns..." do
		  add_column :data_items, :created_at, :timestamp,	:null => false
		  add_column :data_items, :updated_at, :timestamp,	:null => false
		  add_column :data_items, :updated_by, :string,	:null => false, :default => CREATOR_MACRODECK
	  end
  end

  def self.down
	  say_with_time "Renaming columns back..." do
		  rename_column :data_items, :data_type, :datatype
		  rename_column :data_items, :uuid, :dataid
		  rename_column :data_items, :data_group_uuid, :grouping
		  rename_column :data_items, :created_by, :creator
		  rename_column :data_items, :owned_by, :owner
		  rename_column :data_items, :application_uuid, :datacreator
	  end
	  say_with_time "Removing additional columns..." do
		  remove_column :data_items, :created_at
		  remove_column :data_items, :updated_at
		  remove_column :data_items, :updated_by
	  end
  end
end
