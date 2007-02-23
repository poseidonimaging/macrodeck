# This is the the ActiveRecord model that
# represents data items. A bunch of
# convienence methods will be added here
# to help DataService do its job.
# Of course, this means that DataService will
# absolutely not be able to run outside of
# Rails. At least not without some hack.

class DataItem < ActiveRecord::Base
    
    acts_as_ferret :fields => [:tags, :description, :title]        
    
    # write time of item's creation to updated field
    def after_create
        updated = Time.new.to_i
    end

    # write time of item's update to updated field
    def after_update
        updated = Time.new.to_i
    end

	# Finds a group of data based on the grouping
	# UUID specified. Can limit to a certain data
	# type if desired. The order the data is returned
	# can be specified using :desc or :asc.
	def self.findDataByGrouping(groupID, dataType = nil, order = :desc)
		if order == :desc
			sql_order = "DESC"
		elsif order == :asc
			sql_order = "ASC"
		else
			sql_order = "DESC"
		end
		if dataType != nil
			return self.find(:all, :conditions => ["grouping = ? AND datatype = ?", groupID, dataType], :order => "creation #{sql_order}")
		else
			return self.find(:all, :conditions => ["grouping = ?", groupID], :order => "creation #{sql_order}")
		end
	end
	
	# Finds a specific data item based on its ID
	def self.findDataItem(dataID)
		return self.find(:first, :conditions => ["dataid = ?", dataID])
	end
end
