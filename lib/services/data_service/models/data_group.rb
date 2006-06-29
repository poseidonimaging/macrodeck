# This ActiveRecord model is for the data_groups table. 
# This table defines groupings for DataItem objects,
# and gives each group a type. Its columns are
# similar to DataItem.

class DataGroup < ActiveRecord::Base
	# Finds groupings by type, and optionally
	# by their creator.
	def self.findGroupings(dataType, creator = nil)
		if creator != nil
			return self.find(:all, :conditions => ["groupingtype = ? AND creator = ?", dataType, creator])
		else
			return self.find(:all, :conditions => ["groupingtype = ?", dataType])
		end
	end
	
	# Finds groupings by their type and parent
	def self.findGroupingsByParent(dataType, parent)
		return self.find(:all, :conditions => ["groupingtype = ? AND parent = ?", dataType, parent])
	end
end
