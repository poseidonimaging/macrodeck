class RenamePermissionsColumns < ActiveRecord::Migration
  def self.up
    rename_column 'data_groups', 'default_read_permissions', 'read_permissions'
    rename_column 'data_groups', 'default_write_permissions', 'write_permissions'
  end

  def self.down
    rename_column 'data_groups', 'read_permissions', 'default_read_permissions'
    rename_column 'data_groups', 'write_permissions', 'default_write_permissions'  
  end
end
