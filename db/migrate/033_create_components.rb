class CreateComponents < ActiveRecord::Migration
  def self.up
	create_table :components do |t|
		t.column :uuid,				:string
		t.column :name,				:string
		t.column :description,		:text
		t.column :version,			:string
		t.column :homepage,			:string
		t.column :tags,				:string
		t.column :creator,			:string
		t.column :owner,			:string
		t.column :status,			:string # enum: release, beta, alpha
		t.column :dependencies,		:text
		t.column :code,				:text
		t.column :configuration_fields,	:text
	end
  end

  def self.down
	drop_table :components
  end
end
