class MigrateUserCreationAndUpdated < ActiveRecord::Migration
  def self.up
	  say_with_time "Migrating old creation times..." do
		  User.find(:all).each do |u|
			  if u.creation.nil?
				  # somehow we didn't set the creation time.... use now.
				  say "Migrating '#{u.uuid}' [nil creation]"
				  u.update_attribute :created_at, Time.new
			  else
				  say "Migrating '#{u.uuid}'"
				  u.update_attribute :created_at, Time.at(u.creation)
			  end
		  end
	  end
	  say_with_time "Deleting old creation and updated..." do
		  remove_column :users, :creation
	  end
  end

  def self.down
	  say_with_time "Creating the columns we deleted..." do
		  add_column :users, :creation, :integer
	  end
	  say_with_time "Putting the data back..." do
		  User.find(:all).each do |u|
			  u.update_attribute :creation, u.created_at.to_i
		  end
	  end
  end
end
