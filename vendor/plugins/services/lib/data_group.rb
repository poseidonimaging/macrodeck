# This ActiveRecord model is for the data_groups table. 
# This table defines groupings for DataItem objects,
# and gives each group a type. Its columns are
# similar to DataItem.

class DataGroup < ActiveRecord::Base

    acts_as_ferret :fields => [:tags, :description, :title] 

    # write time of group's creation to updated field
    def after_create
        updated = Time.new.to_i
    end

    # write time of group's update to updated field
    def after_update
        updated = Time.new.to_i
    end
 
    def uuid
        self.groupingid 
    end

	# Finds groupings by their type
	def self.findGroupings(dataType, resultsToReturn = :all)
		return self::find(resultsToReturn, :conditions => ["groupingtype = ?", dataType])
	end
	
	# Finds groupings by type and their creator.
	def self.findGroupingsByCreator(dataType, creator, resultsToReturn = :all)
		return self::find(resultsToReturn, :conditions => ["groupingtype = ? AND creator = ?", dataType, creator])
	end
	
	# Finds groupings by type and owner.
	def self.findGroupingsByOwner(dataType, owner, resultsToReturn = :all)
		return self::find(resultsToReturn, :conditions => ["groupingtype = ? AND owner = ?", dataType, owner])
	end
	
	# Finds groupings by their type and parent
	def self.findGroupingsByParent(dataType, parent, resultsToReturn = :all)
		return self::find(resultsToReturn, :conditions => ["groupingtype = ? AND parent = ?", dataType, parent])
	end
end