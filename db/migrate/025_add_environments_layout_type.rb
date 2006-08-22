class AddEnvironmentsLayoutType < ActiveRecord::Migration
  def self.up
	add_column :environments, :layout_type, :string # an enum basically. 
  end

  def self.down
	remove_column :environments, :layout_type
  end
end
