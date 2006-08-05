require 'yaml'

class PopulatePermissions < ActiveRecord::Migration
  def self.up
	# The purpose of this is so there are permissions to work with!
	default_read = [{ :id => "everybody", :action => :allow }]
	default_write = [{ :id => "everybody", :action => :deny }]
	
	say_with_time "Updating DataItems with default permissions..." do
		items = DataItem.find(:all)
		items.each do |item|
			if item.read_permissions == nil || item.read_permissions.length == 0
				write "Setting read permissions for " + item.dataid + "..."
				item.read_permissions = default_read.to_yaml
			end
			if item.write_permissions == nil || item.write_permissions.length == 0
				write "Setting write permissions for " + item.dataid + "..."
				item.write_permissions = default_write.to_yaml
			end
			item.save!
		end
	end
	
	say_with_time "Updating DataGroups with default permissions..." do
		groups = DataGroup.find(:all)
		groups.each do |group|
			if group.default_read_permissions == nil || group.default_read_permissions.length == 0
				write "Setting read permissions for " + group.groupingid + "..."
				group.default_read_permissions = default_read.to_yaml
			end
			if group.default_write_permissions == nil || group.default_write_permissions.length == 0
				write "Setting write permissions for " + group.groupingid + "..."
				group.default_write_permissions = default_write.to_yaml
			end
			group.save!
		end
	end
  end

  def self.down
	raise IrreversibleMigration
  end
end
