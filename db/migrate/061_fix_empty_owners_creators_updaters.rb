class FixEmptyOwnersCreatorsUpdaters < ActiveRecord::Migration
  def self.up
	  say_with_time "Updating DataItems..." do
		  DataItem.find(:all).each do |di|
			  say "Working with '#{di.title}' (#{di.uuid})..."
			  if di.owned_by.nil? || di.owned_by == ""
				  say "   owned_by is nil"
				  di.update_attribute :owned_by, CREATOR_MACRODECK
			  end
			  if di.created_by.nil? || di.created_by == ""
				  say "   created_by is nil"
				  di.update_attribute :created_by, CREATOR_MACRODECK
			  end
			  if di.updated_by.nil? || di.updated_by == ""
				  say "   updated_by is nil"
				  di.update_attribute :updated_by, CREATOR_MACRODECK
			  end
		  end
	  end

	  say_with_time "Updating DataGroups..." do
		  DataGroup.find(:all).each do |dg|
			  say "Working with '#{dg.title}' (#{dg.uuid})..."
			  if dg.owned_by.nil? || dg.owned_by == ""
				  say "   owned_by is nil"
				  dg.update_attribute :owned_by, CREATOR_MACRODECK
			  end
			  if dg.created_by.nil? || dg.created_by == ""
				  say "   created_by is nil"
				  dg.update_attribute :created_by, CREATOR_MACRODECK
			  end
			  if dg.updated_by.nil? || dg.updated_by == ""
				  say "   updated_by is nil"
				  dg.update_attribute :updated_by, CREATOR_MACRODECK
			  end
		  end
	  end
  end

  def self.down
	  # nothing really to do here..
  end
end
