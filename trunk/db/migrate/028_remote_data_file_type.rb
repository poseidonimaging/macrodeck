class RemoteDataFileType < ActiveRecord::Migration
  def self.up
	add_column :data_sources, :file_type, :string # faux-enum for rss, rdf, ical, etc.
  end

  def self.down
	remove_column :data_sources, :file_type
  end
end
