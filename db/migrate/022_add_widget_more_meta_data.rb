class AddWidgetMoreMetaData < ActiveRecord::Migration
  def self.up
	add_column :widgets, :creation, :integer
	add_column :widgets, :updated, :integer
  end

  def self.down
	remove_column :widgets, :creation
	remove_column :widgets, :updated
  end
end
