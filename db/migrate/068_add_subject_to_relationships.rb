class AddSubjectToRelationships < ActiveRecord::Migration
  def self.up
	  add_column :relationships, :subject, :string, :null => true, :default => nil
  end

  def self.down
	  remove_column :relationships, :subject
  end
end
