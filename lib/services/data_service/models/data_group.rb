# This ActiveRecord model is for the data_groups table. 
# This table defines groupings for DataItem objects,
# and gives each group a type. Its columns are
# similar to DataItem.

class DataGroup < ActiveRecord::Base
	# Finds groupings by their type
	def self.findGroupings(dataType)
		return self.find(:all, :conditions => ["groupingtype = ?", dataType])
	end
	
	# Finds groupings by type and their creator.
	def self.findGroupingsByCreator(dataType, creator)
		return self.find(:all, :conditions => ["groupingtype = ? AND creator = ?", dataType, creator])
	end
	
	# Finds groupings by type and owner.
	def self.findGroupingsByOwner(dataType, owner)
		return self.find(:all, :conditions => ["groupingtype = ? AND owner = ?", dataType, owner])
	end
	
	# Finds groupings by their type and parent
	def self.findGroupingsByParent(dataType, parent)
		return self.find(:all, :conditions => ["groupingtype = ? AND parent = ?", dataType, parent])
	end
end
