# This is the the ActiveRecord model that
# represents data items. A bunch of
# convienence methods will be added here
# to help DataService do its job.
# Of course, this means that DataService will
# absolutely not be able to run outside of
# Rails. At least not without some hack.

class DataItem < ActiveRecord::Base
	# Finds a group of data based on the grouping
	# UUID specified. Can limit to a certain data
	# type if desired.
	def self.findDataByGrouping(groupID, dataType = nil)
		if dataType != nil
			return self.find(:all, :conditions => ["grouping = ? AND datatype = ?", groupID, dataType], :order => "creation DESC")
		else
			return self.find(:all, :conditions => ["grouping = ?", groupID], :order => "creation DESC")
		end
	end
	
	# Finds a specific data item based on its ID
	def self.findDataItem(dataID)
		return self.find(:first, :conditions => ["dataid = ?", dataID])
	end
end
