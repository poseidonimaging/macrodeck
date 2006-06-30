# This service handles all of the data for MacroDeck.
# This service *requires* Rails to function due to its
# use of ActiveRecord. I believe that if you were to
# load ActiveRecord, you could probably get away
# with using only ActiveRecord.

require "services/data_service/models/data_item"
require "services/data_service/models/data_group"
require "yaml"

# Constants for data types
DTYPE_POST		= "13569fca-5b8c-4ec3-8738-350165a37592"
DTYPE_EVENT		= "1a5527bb-515b-4f69-807e-facf578e0f2d"
DTYPE_COMMENT	= "9a232c1d-55f7-4edd-8b60-e942eca82ea2"

# Types of groupings
DGROUP_BLOG		= "f7ae8ebd-c49a-4c9c-8f8c-425d32e64d88"
DGROUP_CALENDAR	= "ae32a6aa-bfb2-4126-87a1-7041da0ce6e5"
DGROUP_COMMENTS	= "841d7152-1a50-43c5-b53f-75437faad6a2"

class DataService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.DataService"
	@serviceName = "DataService"	
	@serviceVersionMajor = 1
	@serviceVersionMinor = 0	
	@serviceVersionRevision = 20060628
	@serviceUUID = "ae52b2a9-0872-4651-b159-c37715a53704"
	
	# Returns a string value from the dataID requested or nil
	# if nothing can be found.
	def self.getDataString(dataID)
		value = DataItem.findDataItem(dataID)
		if value.stringdata.class != nil
			if value.stringdata.class == String
				return value.stringdata
			else
				return nil
			end
		else
			# It doesn't have a class method.
			# So something is weird and it's not
			# a string as we expect.
			return nil
		end
	end
	
	# Returns an integer value from the dataID requested or nil
	# if nothing can be found.
	def self.getDataInteger(dataID)
		value = DataItem.findDataItem(dataID)
		if value.integerdata.class != nil
			if value.integerdata.class == Fixnum
				return value.integerdata
			else
				return nil
			end
		else
			return nil
		end
	end
	
	# Returns an object value from the dataID requested or nil
	# if nothing can be found.
	def self.getDataObject(dataID)
		value = DataItem.findDataItem(dataID)
		hashvalue = Hash.new
		if value.objectdata.class != nil
			if value.objectdata.class == String
				hashvalue = YAML.load(value.objectdata.to_s)
				return hashvalue
			else
				return nil
			end
		else
			return nil
		end
	end
end

Services.registerService(DataService)