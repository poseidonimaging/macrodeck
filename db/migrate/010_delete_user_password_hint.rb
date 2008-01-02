class DeleteUserPasswordHint < ActiveRecord::Migration
  def self.up
	remove_column :users, :passwordhint
  end

  def self.down
	add_column :users, :passwordhint, :string
  end
end
