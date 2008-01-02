class AddUpdatedField < ActiveRecord::Migration
    def self.up
        add_column :data_items, :updated, :integer
        add_column :data_groups, :updated, :integer
        add_column :storages, :updated, :integer
    end

    def self.down
        remove_column :data_items, :updated
        remove_column :data_groups, :updated
        remove_column :storages, :updated        
    end
end
