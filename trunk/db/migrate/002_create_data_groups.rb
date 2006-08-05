class CreateDataGroups < ActiveRecord::Migration
  def self.up
	create_table :data_groups do |t|
		t.column :groupingtype,			:string
		t.column :creator,				:string
		t.column :groupingid,			:string
		t.column :owner,				:string
		t.column :tags,					:text
	end  
  end

  def self.down
	drop_table :data_groups
  end
end
