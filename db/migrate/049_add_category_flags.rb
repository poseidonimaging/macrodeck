class AddCategoryFlags < ActiveRecord::Migration
  def self.up
	add_column :categories, :can_have_items, :boolean	# Can the category contain items, or just other categories?
  end

  def self.down
	remove_column :categories, :can_have_items
  end
end
