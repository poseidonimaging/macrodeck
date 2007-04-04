# I have no idea how I forgot to do this... 
class AddDataGroupCreation < ActiveRecord::Migration
  def self.up
	  add_column :data_groups, :creation, :integer
  end

  def self.down
	  remove_column :data_groups, :creation
  end
end
