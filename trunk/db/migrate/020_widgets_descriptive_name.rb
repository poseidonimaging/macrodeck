class WidgetsDescriptiveName < ActiveRecord::Migration
  def self.up
	rename_column :widgets, :name, :descriptive_name
	add_column :widgets, :internal_name, :string
  end

  def self.down
	remove_column :widgets, :internal_name
	rename_column :widgets, :descriptive_name, :name
  end
end
