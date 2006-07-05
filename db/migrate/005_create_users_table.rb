class CreateUsersTable < ActiveRecord::Migration
  def self.up
	create_table :users do |t|
		t.column :uuid,				:string
		t.column :username,			:string
		t.column :password,			:string
		t.column :passwordhint,		:string
		t.column :secretquestion,	:string
		t.column :secretanswer,		:string
		t.column :name,				:string
		t.column :displayname,		:string
		t.column :creation,			:integer
		t.column :dob,				:date
	end
  end

  def self.down
	drop_table :users
  end
end
