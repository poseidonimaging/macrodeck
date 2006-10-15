class AddAuthCookie < ActiveRecord::Migration
  def self.up
	add_column :users, :authcookie, :string
	add_column :users, :authcookie_set_time, :integer
  end

  def self.down
	remove_column :users, :authcookie
	remove_column :users, :authcookie_set_time
  end
end
