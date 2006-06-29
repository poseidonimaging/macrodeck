class AddDataGroupTitleDescription < ActiveRecord::Migration
  def self.up
	add_column :data_groups, :title,		:string
	add_column :data_groups, :description,	:text
  end

  def self.down
	remove_column :data_groups, :title
	remove_column :data_groups, :description
  end
end
