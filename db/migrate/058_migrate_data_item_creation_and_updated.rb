class MigrateDataItemCreationAndUpdated < ActiveRecord::Migration
  def self.up
	  say_with_time "Migrating old creation times..." do
		  DataItem.find(:all).each do |di|
			  if di.creation.nil?
				  # somehow we didn't set the creation time.... use now.
				  say "Migrating '#{di.title}' (#{di.uuid}) [nil creation]"
				  di.update_attribute :created_at, Time.new
			  else
				  say "Migrating '#{di.title}' (#{di.uuid})"
				  di.update_attribute :created_at, Time.at(di.creation)
			  end
		  end
	  end
	  say_with_time "Migrating old updated times..." do
		  DataItem.find(:all).each do |di|
			  if di.updated.nil?
				  # somehow we didn't set the creation time.... use now.
				  say "Migrating '#{di.title}' (#{di.uuid}) [nil updated]"
				  di.update_attribute :updated_at, Time.new
			  else
				  say "Migrating '#{di.title}' (#{di.uuid})"
				  di.update_attribute :updated_at, Time.at(di.updated)
			  end
		  end
	  end
	  say_with_time "Deleting old creation and updated..." do
		  remove_column :data_items, :updated
		  remove_column :data_items, :creation
	  end
  end

  def self.down
	  say_with_time "Creating the columns we deleted..." do
		  add_column :data_items, :updated, :integer
		  add_column :data_items, :creation, :integer
	  end
	  say_with_time "Putting the data back..." do
		  DataItem.find(:all).each do |dg|
			  di.update_attribute :creation, di.created_at.to_i
			  di.update_attribute :updated, di.updated_at.to_i
		  end
	  end
  end
end
