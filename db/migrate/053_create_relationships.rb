class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
		t.column	:source_uuid,	:string,	:null => false
		t.column	:target_uuid,	:string,	:null => false
		t.column	:relationship,	:string,	:null => false # this will be a word or something, e.g. "patron"
		t.column	:created_at,	:datetime,	:null => false
		t.column	:updated_at,	:datetime,	:null => false
    end
  end

  def self.down
    drop_table :relationships
  end
end
