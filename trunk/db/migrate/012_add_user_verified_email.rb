class AddUserVerifiedEmail < ActiveRecord::Migration
  def self.up
	add_column :users, :verified_email, :boolean
  end

  def self.down
	remove_column :users, :verified_email
  end
end
