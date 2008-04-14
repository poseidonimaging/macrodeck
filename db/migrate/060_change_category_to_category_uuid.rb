class ChangeCategoryToCategoryUuid < ActiveRecord::Migration
  def self.up
	  rename_column :data_groups, :category, :category_uuid
  end

  def self.down
	  rename_column :data_groups, :category_uuid, :category
  end
end
