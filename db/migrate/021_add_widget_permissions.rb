class AddWidgetPermissions < ActiveRecord::Migration
  def self.up
	add_column :widgets, :read_permissions, :text
	add_column :widgets, :write_permissions, :text
  end

  def self.down
	remove_column :widgets, :read_permissions
	remove_column :widgets, :write_permissions
  end
end
