class CreateWidgets < ActiveRecord::Migration
  def self.up
	create_table :widgets do |t|
		t.column :uuid,				:string
		t.column :name,				:string
		t.column :description,		:text
		t.column :version,			:string
		t.column :homepage,			:string
		t.column :tags,				:string
		t.column :creator,			:string
		t.column :owner,			:string
		t.column :status,			:string # enum: release, beta, alpha
		t.column :dependencies,		:text
		t.column :code,				:text
		t.column :configuration_fields,	:text
	end
	create_table :widget_instances do |t|
		t.column :instanceid,		:string
		t.column :widgetid,			:string
		t.column :parent,			:string # the parent page/environment/etc.
		t.column :configuration,	:text
		t.column :position,			:integer # the column or box number for an environment/page
		t.column :order,			:integer # the order to put the widget in the position specified.
	end
  end

  def self.down
	drop_table :widgets
	drop_table :widget_instances
  end
end
