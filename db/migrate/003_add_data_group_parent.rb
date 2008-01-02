class AddDataGroupParent < ActiveRecord::Migration
  def self.up
	add_column :data_groups, :parent, :string
  end

  def self.down
	remove_column :data_groups, :parent
  end
end
