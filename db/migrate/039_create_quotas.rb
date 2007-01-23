class CreateQuotas < ActiveRecord::Migration
  def self.up
    create_table :quotas do |t|
      t.column :storageid, :string
      t.column :objectid, :string      
      t.column :max_file_size, :string
      t.column :max_total_size, :string
    end
  end

  def self.down
    drop_table :quotas
  end
end
