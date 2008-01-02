class CreateStorages < ActiveRecord::Migration
  def self.up
    create_table :storages do |t|
      t.column :objectid, :string
      t.column :objecttype, :string
      t.column :data, :blob
      t.column :parent, :string
      t.column :title, :string        # metadata   
      t.column :creator, :string      # metadata
      t.column :creatorapp, :string   # metadata
      t.column :owner, :string        # metadata   
      t.column :tags, :text           # metadata   
      t.column :description, :text    # metadata   
      t.column :read_permissions, :text
      t.column :write_permissions, :text
   #   t.column :quotas, :text
    end
  end
  
  def self.down
	drop_table :data_groups
  end
end