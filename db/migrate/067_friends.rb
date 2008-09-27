class Friends < ActiveRecord::Migration
  def self.up
	create_table :friends, :id => false do |t|
		t.column :friend_id,	:integer
		t.column :user_id,	:integer
	end

	add_index :friends, :friend_id
	add_index :friends, :user_id
  end

  def self.down
	drop_table :friends
  end
end
