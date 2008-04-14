class OhYeahWeCantUseType < ActiveRecord::Migration
  def self.up
	  # In my infinite wisdom I named a column "type", which is bad, because type happens to be
	  # reserved in Ruby....
	  rename_column :data_groups, :type, :data_type
  end

  def self.down
	  rename_column :data_groups, :data_type, :type
  end
end
