class MakeDataGroupsSuckLess < ActiveRecord::Migration
  def self.up
	  # This migration will rename all of the columns to enhance sanity. We also
	  # add a couple NOT NULL restrictions so that errors can't happen anymore.
	  #
	  # It will also add a couple of columns for creation date and migrate the old
	  # UNIX timestamp creations/updateds.
	  say_with_time "Renaming columns..." do
		  rename_column :data_groups, :groupingtype, :type
		  rename_column :data_groups, :groupingid, :uuid
		  rename_column :data_groups, :parent, :parent_uuid
		  rename_column :data_groups, :creator, :created_by
		  rename_column :data_groups, :owner, :owned_by
	  end
	  say_with_time "Changing column settings..." do
		  change_column :data_groups, :created_by,	:string,	:null => false, :default => CREATOR_MACRODECK
		  change_column :data_groups, :owned_by,	:string,	:null => false, :default => CREATOR_MACRODECK
	  end
	  say_with_time "Adding columns..." do
		  add_column :data_groups, :created_at, :timestamp,	:null => false
		  add_column :data_groups, :updated_at, :timestamp,	:null => false
		  add_column :data_groups, :updated_by, :string,	:null => false, :default => CREATOR_MACRODECK
	  end
  end

  def self.down
	  say_with_time "Renaming columns back..." do
		  rename_column :data_groups, :type, :groupingtype
		  rename_column :data_groups, :uuid, :groupingid
		  rename_column :data_groups, :parent_uuid, :parent
		  rename_column :data_groups, :created_by, :creator
		  rename_column :data_groups, :owned_by, :owner
	  end
	  say_with_time "Changing column settings back..." do
		  change_column :data_groups, :creator,	:string, :null => true, :default => nil
		  change_column :data_groups, :owner,	:string, :null => true, :default => nil
	  end
	  say_with_time "Removing additional columns..." do
		  remove_column :data_groups, :created_at
		  remove_column :data_groups, :updated_at
		  remove_column :data_groups, :updated_by
	  end
  end
end
