class AddUsersAuthCode < ActiveRecord::Migration
  def self.up
	add_column :users, :authcode, :string
  end

  def self.down
	remove_column :users, :authcode
  end
end
