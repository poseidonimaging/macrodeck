class PermissionsForComponents < ActiveRecord::Migration
  def self.up
	add_column :components, :read_permissions, :text
	add_column :components, :write_permissions, :text
  end

  def self.down
	remove_column :components, :read_permissions
	remove_column :components, :write_permissions
  end
end
