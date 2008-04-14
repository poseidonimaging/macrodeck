class WhoopsNeedToLimitAdditionalDataGroupThings < ActiveRecord::Migration
  def self.up
	  change_column :data_groups, :uuid,		:string, :null => false # require uuid
	  change_column :data_groups, :data_type,	:string, :null => false # require data type
  end

  def self.down
	  change_column :data_groups, :uuid,		:string, :null => true
	  change_column :data_groups, :data_type,	:string, :null => true
  end
end
