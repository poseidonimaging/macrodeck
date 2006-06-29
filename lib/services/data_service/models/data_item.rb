# This is the the ActiveRecord model that
# represents data items. A bunch of
# convienence methods will be added here
# to help DataService do its job.
# Of course, this means that DataService will
# absolutely not be able to run outside of
# Rails. At least not without some hack.

class DataItem < ActiveRecord::Base
	# Finds a group of data based on the
	# grouping UUID specified.
	def self.findDataGroup(groupID)
	end
end
