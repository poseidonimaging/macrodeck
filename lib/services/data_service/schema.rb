# DataService Schema
#
# This file contains all of the schema information
# for the DataService tables and such.

ActiveRecord::Schema.define do
	create_table :data_items do |t|
		t.column :datatype,				:string
		t.column :datacreator,			:string
		t.column :dataid,				:string
		t.column :grouping,				:string
		t.column :owner,				:string
		t.column :creator,				:string
		t.column :creation,				:integer
		t.column :tags,					:text
		t.column :title,				:string
		t.column :description,			:text
		t.column :stringdata,			:text
		t.column :integerdata,			:integer
		t.column :objectdata,			:text
		t.column :read_permissions,		:string
		t.column :write_permissions,	:string
	end
end