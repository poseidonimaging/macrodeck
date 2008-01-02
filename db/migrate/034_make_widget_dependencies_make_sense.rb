class MakeWidgetDependenciesMakeSense < ActiveRecord::Migration
  def self.up
	rename_column :widgets, :dependencies, :required_components
  end

  def self.down
	rename_column :widgets, :required_components, :dependencies
  end
end
