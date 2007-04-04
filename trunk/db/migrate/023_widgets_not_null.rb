class WidgetsNotNull < ActiveRecord::Migration
  def self.up
	change_column :widgets, :creation, :integer, { :default => 0, :null => false }
	change_column :widgets, :updated, :integer, { :default => 0, :null => false }
  end

  def self.down
	change_column :widgets, :creation, :integer, { :null => true }
	change_column :widgets, :updated, :integer, { :null => true }
  end
end
