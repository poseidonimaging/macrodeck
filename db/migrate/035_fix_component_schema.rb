class FixComponentSchema < ActiveRecord::Migration
  def self.up
	rename_column :components, :name, :descriptive_name
	remove_column :components, :dependencies
	remove_column :components, :configuration_fields
	add_column :components, :internal_name, :string
  end

  def self.down
	rename_column :components, :descriptive_name, :name
	add_column :components, "dependencies", :text
	add_column :components, "configuration_fields", :text
	remove_column :components, :internal_name
  end
end
