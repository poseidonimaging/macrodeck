# This ActiveRecord model is for the data_groups table. 
# This table defines groupings for DataItem objects,
# and gives each group a type. Its columns are
# similar to DataItem.

class DataGroup < ActiveRecord::Base

    acts_as_ferret :fields => [:tags, :description, :title] 
    UUID = 

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
    
    # It's just a alias to make this model close to DataItem 
    def type
        self.groupingtype
    end

	# Returns true if there are data items in this grouping.
	def items?
		ditems = DataItem.find(:all, :conditions => ["grouping = ?", groupingid])
		if ditems != nil && ditems.length > 0
			return true
		else
			return false
		end
	end

	# Returns data items in this grouping
	def items
		ditems = DataItem.find(:all, :conditions => ["grouping = ?", groupingid])
		return ditems
	end

	# Returns a human-readable version of the creation
	def human_creation
		if creation != nil
			return Time.at(creation).strftime("%B %d, %Y at %I:%M %p")
		else
			return "Unknown"
		end
	end

	# Returns a human-readable version of the updated time.
	def human_updated
		if updated != nil
			return Time.at(updated).strftime("%B %d, %Y at %I:%M %p")
		else
			return "Unknown"
		end
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
