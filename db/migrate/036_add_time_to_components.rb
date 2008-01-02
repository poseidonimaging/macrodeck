class AddTimeToComponents < ActiveRecord::Migration
  def self.up
	add_column :components, :creation, :integer, { :default => 0, :null => false }
	add_column :components, :updated, :integer, { :default => 0, :null => false }
  end

  def self.down
	remove_column :components, :creation
	remove_column :components, :updated
  end
end
