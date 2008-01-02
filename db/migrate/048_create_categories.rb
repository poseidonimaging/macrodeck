class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
		t.column :uuid, :string
		t.column :title, :string
		t.column :description, :text
		t.column :url_part, :string # URL-compatible name (us for "United States", ok for "Oklahoma", oklahoma-city for "Oklahoma City")
		t.column :parent, :string
    end
	add_column :data_groups, :category, :string
	# Items are not placed into categories because they ALREADY belong to DataGroups, which are grouping the data already.
	# Basically cateogires are a way to index data groups.
  end

  def self.down
    drop_table :categories
	remove_column :data_groups, :category
  end
end
