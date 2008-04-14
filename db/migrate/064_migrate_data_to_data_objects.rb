# THE BIGGEST MIGRATION EVER!
# Okay, not really. This moves all of the data from the dumb two-table-no-sane-foreign-keys system
# to the new, fresh-smelling system.

gem "rfacebook", ">= 0.9.3"

require 'yaml'
require 'data_service/data_group'
require 'data_service/data_item'
require 'data_service/data_object'
require 'user_service/user'
require 'places_service/place'
require 'places_service/city'
require 'comment_service/comment'
require 'comment_service/comments'
require 'default_uuids'
require 'local_uuids'

class MigrateDataToDataObjects < ActiveRecord::Migration
  def self.up
	  say_with_time "Migrating DataItem/DataGroup tree to DataObject" do
		  root_groups = DataGroup::find(:all, :conditions => ["parent_uuid IS NULL"])
		  root_groups.each do |root_group|
			  say "Migrating Root Group '#{root_group.title}' (#{root_group.uuid})"
			  self.migrate_data_group(nil, root_group)
		  end
	  end
  end

  # takes a data item and migrates it
  def self.migrate_data_item(parent_id,item)
	  say "--- Migrating data item '#{item.title}' (#{item.uuid})"
	  new_type = nil
	  case item.data_type
	  when DTYPE_PLACE
		  new_type = "Place"
	  when DTYPE_CITY
		  new_type = "City"
	  when DGROUP_BLOG
		  new_type = "Blog"
	  when DTYPE_COMMENT
		  new_type = "Comment"
	  when DTYPE_COMMENTS
		  new_type = "Comments"
	  else
		  new_type = "DataObject"
		  say "!!! Unhandled source data type: #{item.data_type}"
	  end
	  if item.remote_data == true
		  say "!!! Ignoring remote data as it's known broken! (#{item.uuid})"
	  else
		  data_obj = DataObject::new({
			  :parent_id		=> parent_id,
			  :type				=> new_type,
			  :uuid				=> item.uuid,
			  :title			=> item.title,
			  :description		=> item.description,
			  :data				=> item.stringdata,
			  :created_at		=> item.created_at,
			  :updated_at		=> item.updated_at,
			  # Foreign Keys!
			  :created_by		=> User::find_by_uuid(item.created_by),
			  :updated_by		=> User::find_by_uuid(item.updated_by),
			  :owned_by			=> User::find_by_uuid(item.owned_by)
		  })
		  data_obj.type = new_type
		  if !item.objectdata.nil?
			  data_obj.extended_data = YAML::load(item.objectdata)
		  end
		  data_obj.save!
		  say "+++ Migrated data item '#{data_obj.title}' (#{data_obj.uuid})"
		  if item.children?
			  item.children.each do |child|
				  self.migrate_data_group(data_obj.id, child)
			  end
		  end
	  end
  end

  # takes a data group and migrates it
  def self.migrate_data_group(parent_id,group)
	  say "--- Migrating data group '#{group.title}' (#{group.uuid})"
	  new_type = nil
	  case group.data_type
	  when DTYPE_PLACE
		  new_type = "Place"
	  when DTYPE_CITY
		  new_type = "City"
	  when DGROUP_BLOG
		  new_type = "Blog"
	  when DTYPE_COMMENT
		  new_type = "Comment"
	  when DTYPE_COMMENTS
		  new_type = "Comments"
	  else
		  new_type = "DataObject"
		  say "!!! Unhandled source data type: #{item.data_type}"
	  end
	  if group.remote_data == true
		  say "!!! Ignoring remote data as it's known broken! (#{group.uuid})"
	  else
	  	# Get IDs for each updater, creator, and owner
		created_by_id = User::find_by_uuid(group.created_by).id if !group.created_by.nil?
		created_by_id = 0 if group.created_by.nil?
		updated_by_id = User::find_by_uuid(group.updated_by).id if !group.updated_by.nil?
		updated_by_id = 0 if group.updated_by.nil?
		owned_by_id = User::find_by_uuid(group.owned_by).id if !group.owned_by.nil?
		owned_by_id = 0 if group.owned_by.nil?

		  data_obj = DataObject::new({
			  :parent_id		=> parent_id,
			  :type				=> new_type,
			  :uuid				=> group.uuid,
			  :title			=> group.title,
			  :description		=> group.description,
			  :created_at		=> group.created_at,
			  :updated_at		=> group.updated_at,
			  # Foreign Keys!
			  :category			=> Category::find_by_uuid(group.category_uuid),
			  :created_by_id		=> created_by_id,
			  :updated_by_id		=> updated_by_id,
			  :owned_by_id			=> owned_by_id
		  })
		  data_obj.type = new_type
		  data_obj.save!
		  say "+++ Migrated data group '#{data_obj.title}' (#{data_obj.uuid})"
		  subitems = DataItem::find(:all, :conditions => ["data_group_uuid = ?", data_obj.uuid])
		  if !subitems.empty?
			  subitems.each do |subitem|
				  self.migrate_data_item(data_obj.id, subitem)
			  end
		  end
	  end
  end

  def self.down
	  # Nothing we can do here.
  end
end
