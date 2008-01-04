class RenameCategoryParentToParentUuid < ActiveRecord::Migration
  def self.up
	  rename_column :categories, :parent, :parent_uuid
  end

  def self.down
	  rename_column :categories, :parent_uuid, :parent
  end
end
