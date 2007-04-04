class MakeIsBannedNotNull < ActiveRecord::Migration
  def self.up
	change_column(:group_members, :isbanned, :boolean, :null => false)
  end

  def self.down
	change_column(:group_members, :isbanned, :boolean, :null => true)
  end
end
