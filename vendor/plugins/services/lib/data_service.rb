# This service handles all of the data for MacroDeck.
# This service *requires* Rails to function due to its
# use of ActiveRecord. I believe that if you were to
# load ActiveRecord, you could probably get away
# with using only ActiveRecord.


require "data_item"		# DataItem model
require "data_group"	# DataGroup model
require "yaml"

# Constants for data types

DTYPE_POST		= "13569fca-5b8c-4ec3-8738-350165a37592" # A blog post.
DTYPE_EVENT		= "1a5527bb-515b-4f69-807e-facf578e0f2d" # A calendar event.
DTYPE_COMMENT	= "9a232c1d-55f7-4edd-8b60-e942eca82ea2" # A blog post comment.

# Constants for data groups

DGROUP_BLOG		= "f7ae8ebd-c49a-4c9c-8f8c-425d32e64d88" # A user/group/site's blog.
DGROUP_CALENDAR	= "ae32a6aa-bfb2-4126-87a1-7041da0ce6e5" # A calendar.
DGROUP_COMMENTS	= "841d7152-1a50-43c5-b53f-75437faad6a2" # A blog post's comments.

class DataService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.DataService"
	@serviceName = "DataService"	
	@serviceVersionMajor = 1
	@serviceVersionMinor = 0	
	@serviceVersionRevision = 20060704
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
	
	# Creates a new string value with the information provided.
	# +creatorApp+ may be nil; in that case, DataService will be
	# the creator. +grouping+ may also be nil. If it is nil, a
	# UUID will be generated. +title+, +description+, and +tags+
	# may also be nil, but will be stored as nil in the database.
	# Temporarily, +readPermissions+ and +writePermissions+ may be
	# nil, but this is subject to change.
	#
	# Returns the object's data ID, raises an exception if something
	# gnarly happened.
	def self.createDataString(dataType, creatorApp, grouping, creator, owner, tags, title, description, data, readPermissions, writePermissions)
		dataObj = DataItem.new
		if creatorApp == nil
			creatorApp = @serviceUUID
		end
		if grouping == nil
			grouping = UUIDService.generateUUID
		end
		dataObj.datatype = dataType
		dataObj.datacreator = creatorApp
		dataObj.dataid = UUIDService.generateUUID
		dataObj.grouping = grouping
		dataObj.owner = owner
		dataObj.creator = creator
		dataObj.creation = Time.now.to_i
		dataObj.tags = tags
		dataObj.title = title
		dataObj.description = description
		dataObj.stringdata = data
		dataObj.read_permissions = readPermissions
		dataObj.write_permissions = writePermissions
		dataObj.save!
		return dataObj.dataid
	end
	
	# This function works much like createDataString except that
	# it saves an integer
	def self.createDataInteger(dataType, creatorApp, grouping, creator, owner, tags, title, description, data, readPermissions, writePermissions)
		dataObj = DataItem.new
		if creatorApp == nil
			creatorApp = @serviceUUID
		end
		if grouping == nil
			grouping = UUIDService.generateUUID
		end
		dataObj.datatype = dataType
		dataObj.datacreator = creatorApp
		dataObj.dataid = UUIDService.generateUUID
		dataObj.grouping = grouping
		dataObj.owner = owner
		dataObj.creator = creator
		dataObj.creation = Time.now.to_i
		dataObj.tags = tags
		dataObj.title = title
		dataObj.description = description
		dataObj.integerdata = data
		dataObj.read_permissions = readPermissions
		dataObj.write_permissions = writePermissions
		dataObj.save!
		return dataObj.dataid
	end
	
	# This function works much like createDataString except that
	# it saves a hash as YAML (hashes are very complex objects,
	# so they should work for all other kinds of data)
	def self.createDataObject(dataType, creatorApp, grouping, creator, owner, tags, title, description, data, readPermissions, writePermissions)
		dataObj = DataItem.new
		if creatorApp == nil
			creatorApp = @serviceUUID
		end
		if grouping == nil
			grouping = UUIDService.generateUUID
		end
		dataObj.datatype = dataType
		dataObj.datacreator = creatorApp
		dataObj.dataid = UUIDService.generateUUID
		dataObj.grouping = grouping
		dataObj.owner = owner
		dataObj.creator = creator
		dataObj.creation = Time.now.to_i
		dataObj.tags = tags
		dataObj.title = title
		dataObj.description = description
		dataObj.objectdata = data.to_yaml
		dataObj.read_permissions = readPermissions
		dataObj.write_permissions = writePermissions
		dataObj.save!
		return dataObj.dataid
	end
	
	# Creates a new data grouping with the specified parameters.
	# +groupingID+ may be nil, if so, it will be generated in
	# this function.
	def self.createDataGroup(groupType, groupingID, title, description, tags, creator, owner, parent)
		if groupingID == nil
			groupingID = UUIDService.generateUUID
		end
		group = DataGroup.new
		group.groupingtype = groupType
		group.creator = creator
		group.groupingid = groupingID
		group.owner = owner
		group.tags = tags
		group.parent = parent
		group.title = title
		group.description = description
		group.save!
	end
	
	# Returns the owner of the data group specified (by its groupingID)
	def self.getDataGroupOwner(groupingID)
		group = DataGroup::find(:first, :conditions => ["groupingid = ?", groupingID])
		return group.owner
	end
	
	# Returns the creator of the data group specified (by its groupingID)
	def self.getDataGroupCreator(groupingID)
		group = DataGroup::find(:first, :conditions => ["groupingid = ?", groupingID])
		return group.creator
	end
	
	# Returns the owner of the data item specified (by its dataID)
	def self.getDataItemOwner(dataID)
		item = DataItem::find(:first, :conditions => ["dataid = ?", dataID])
		return item.owner
	end
	
	# Returns the creator of the data item specified (by its dataID)
	def self.getDataItemCreator(dataID)
		item = DataItem::find(:first, :conditions => ["dataid = ?", dataID])
		return item.creator
	end
	
	# Finds a data grouping.
	#
	# +searchBy+ may be :type, :parent, :creator, or :owner,
	# and +query+ is the particular parent, creator, or
	# owner you wish to look for. If you're looking by
	# type only, query should be nil.
	def self.findDataGrouping(type, searchBy, query)
		case searchBy
			when :parent, "parent"
				data = DataGroup.findGroupingsByParent(type, query)
				return data
			when :creator, "creator"
				data = DataGroup.findGroupingsByCreator(type, query)
				return data
			when :owner, "owner"
				data = DataGroup.findGroupingsByOwner(type, query)
				return data
			when :type, "type"
				data = DataGroup.findGroupings(type)
				return data
			else
				return nil
		end
	end
end

Services.registerService(DataService)