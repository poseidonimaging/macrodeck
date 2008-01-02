require 'yaml'

class PopulateMacroDeckPermissions < ActiveRecord::Migration
  def self.up
	macrodeck_read	= [{ :id => "everybody", :action => :allow }]
	macrodeck_write	= [{ :id => USER_ZIGGYTHEHAMSTER, :action => :allow },
					   { :id => USER_CSAKON, :action => :allow },
					   { :id => "everybody", :action => :deny }]
	say_with_time "Updating MacroDeck Blog..." do
		dgroups = DataGroup.find(:all, :conditions => ["owner = ?", GROUP_MACRODECK])
		if dgroups != nil
			dgroups.each do |dgroup|
				dgroup.default_read_permissions = macrodeck_read.to_yaml
				dgroup.default_write_permissions = macrodeck_write.to_yaml
				dgroup.save!
			end
		end
	end
	say_with_time "Updating MacroDeck blog entries..." do
		ditems = DataItem.find(:all, :conditions => ["grouping = ?", BLOG_MACRODECK])
		if ditems != nil
			ditems.each do |ditem|
				ditem.read_permissions = macrodeck_read.to_yaml
				ditem.write_permissions = macrodeck_write.to_yaml
				ditem.save!
			end
		end
	end
  end

  def self.down
	raise IrreversibleMigration  
  end
end
