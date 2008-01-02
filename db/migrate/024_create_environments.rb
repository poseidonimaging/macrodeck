class CreateEnvironments < ActiveRecord::Migration
  def self.up
    create_table :environments do |t|
		t.column :uuid,				:string
		t.column :short_name,		:string
		t.column :title,			:string
		t.column :description,		:text
		t.column :creator,			:string
		t.column :owner,			:string
		t.column :creation,			:integer
		t.column :read_permissions,	:text
		t.column :write_permissions,:text
    end
  end

  def self.down
    drop_table :environments
  end
end
