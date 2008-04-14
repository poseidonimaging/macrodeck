class MigrateDataGroupCreationAndUpdated < ActiveRecord::Migration
  def self.up
	  say_with_time "Migrating old creation times..." do
		  DataGroup.find(:all).each do |dg|
			  if dg.creation.nil?
				  # somehow we didn't set the creation time.... use now.
				  say "Migrating '#{dg.title}' (#{dg.uuid}) [nil creation]"
				  dg.update_attribute :created_at, Time.new
			  else
				  say "Migrating '#{dg.title}' (#{dg.uuid})"
				  dg.update_attribute :created_at, Time.at(dg.creation)
			  end
		  end
	  end
	  say_with_time "Migrating old updated times..." do
		  DataGroup.find(:all).each do |dg|
			  if dg.updated.nil?
				  # somehow we didn't set the creation time.... use now.
				  say "Migrating '#{dg.title}' (#{dg.uuid}) [nil updated]"
				  dg.update_attribute :updated_at, Time.new
			  else
				  say "Migrating '#{dg.title}' (#{dg.uuid})"
				  dg.update_attribute :updated_at, Time.at(dg.updated)
			  end
		  end
	  end
	  say_with_time "Deleting old creation and updated..." do
		  remove_column :data_groups, :updated
		  remove_column :data_groups, :creation
	  end
  end

  def self.down
	  say_with_time "Creating the columns we deleted..." do
		  add_column :data_groups, :updated, :integer
		  add_column :data_groups, :creation, :integer
	  end
	  say_with_time "Putting the data back..." do
		  DataGroup.find(:all).each do |dg|
			  dg.update_attribute :creation, dg.created_at.to_i
			  dg.update_attribute :updated, dg.updated_at.to_i
		  end
	  end
  end
end
