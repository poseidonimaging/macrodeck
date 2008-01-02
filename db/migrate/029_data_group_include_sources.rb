class DataGroupIncludeSources < ActiveRecord::Migration
  def self.up
	add_column :data_groups, :include_sources, :text
  end

  def self.down
	remove_column :data_groups, :include_sources
  end
end
