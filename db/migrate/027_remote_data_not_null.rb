class RemoteDataNotNull < ActiveRecord::Migration
  def self.up
	change_column :data_items, :remote_data, :boolean, { :default => 0, :null => false }
	change_column :data_groups, :remote_data, :boolean, { :default => 0, :null => false }
	change_column :data_sources, :creation, :integer, { :default => 0, :null => false }
	change_column :data_sources, :updated, :integer, { :default => 0, :null => false }
	change_column :data_sources, :update_interval, :integer, { :default => 0, :null => false }
  end

  def self.down
	change_column :data_items, :remote_data, :boolean, { :default => 0, :null => true }
	change_column :data_groups, :remote_data, :boolean, { :default => 0, :null => true }
	change_column :data_sources, :creation, :integer, { :default => 0, :null => true }
	change_column :data_sources, :updated, :integer, { :default => 0, :null => true }
	change_column :data_sources, :update_interval, :integer, { :default => 0, :null => true }  
  end
end
