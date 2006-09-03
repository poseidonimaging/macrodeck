class FixRemoteData < ActiveRecord::Migration
  def self.up
	rename_column :data_sources, :type, :data_type
  end

  def self.down
	rename_column :data_sources, :data_type, :type
  end
end
