class ConvertPermissionsToText < ActiveRecord::Migration
  def self.up
	change_column(:data_items, :read_permissions, :text)
	change_column(:data_items, :write_permissions, :text)
  end

  def self.down
	change_column(:data_items, :read_permissions, :string)
	change_column(:data_items, :write_permissions, :string)
  end
end
