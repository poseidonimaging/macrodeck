class FacebookUidIsString < ActiveRecord::Migration
  def self.up
	change_column :users, :facebook_uid, :string
  end

  def self.down
	change_column :users, :facebook_uid, :integer
  end
end
