class AddDataGroupDefaultPermissions < ActiveRecord::Migration
  def self.up
	add_column :data_groups, :default_read_permissions, :text
	add_column :data_groups, :default_write_permissions, :text
  end

  def self.down
	remove_column :data_groups, :default_read_permissions
	remove_column :data_groups, :default_write_permissions
  end
end
