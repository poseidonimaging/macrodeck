# This service handles all of the data for MacroDeck.
# This service *requires* Rails to function due to its
# use of ActiveRecord. I believe that if you were to
# load ActiveRecord, you could probably get away
# with using only ActiveRecord.


require "data_item"		# DataItem model
require "data_group"	# DataGroup model
require "yaml"

class DataService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.DataService"
	@serviceName = "DataService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 2
	@serviceVersionRevision = 20060705
	@serviceUUID = "ae52b2a9-0872-4651-b159-c37715a53704"
	
	# Gets the specified data, by type (:string, :integer, :object),
	# of the data item specified
	def self.getData(dataID, dataType)
		ditem = DataItem.findDataItem(dataID)
		h = Hash.new
		if ditem != nil
			case dataType
				when :string, "string"
					return ditem.stringdata
				when :integer, "integer"
					return ditem.integerdata
				when :object, "object"
					h = YAML.load(ditem.objectdata.to_s)
					return h
				else
					return nil
			end
		else
			return nil
		end
	end
	
	# Creates a data item with the type and value specified.
	# +dataType+ is a UUID that indicates the type of data
	# kept in this data item. For example, a blog entry is
	# a type of data.
	# +valueType+ may be :string, :object, or :integer, and is
	# the kind of data stored in dataValue.
	# +metadata+ is optional, but if used, should be a hash
	# that looks like this (include only the metadata you want
	# to set):
	#
	#  {
	#  :creator => "UUID",
	#  :creatorapp => "UUID", # the UUID of the service/widget/application that created the item
	#  :description => "A bunch of photos from QuakeCon 2006",
	#  :grouping => "UUID",
	#  :owner => "UUID",
	#  :tags => "personal, images",
	#  :title => "QuakeCon 2006 Photos"
	#  }
	#
	# Keep in mind that permissions should get set via setPermissions if the
	# defaults don't suit you. If this item belongs to a pre-existing grouping,
	# and that grouping has default permissions, those will be applied.
	#
	# Returns the data item's UUID if successful, raises an exception if not.
	def self.createData(dataType, valueType, dataValue, metadata = nil)
		dataObj = DataItem.new
		if metadata != nil
			creator = metadata[:creator]
			creatorApp = metadata[:creatorapp]
			description = metadata[:description]
			grouping = metadata[:grouping]
			owner = metadata[:owner]
			tags = metadata[:tags]
			title = metadata[:title]
		else
			creator = nil
			creatorApp = nil
			description = nil
			grouping = nil
			owner = nil
			tags = nil
			title = nil
		end
		if creator == nil
			creator = NOBODY
		end
		if creatorApp == nil
			creatorApp = @serviceUUID
		end
		if grouping == nil
			grouping = UUIDService.generateUUID
		end
		if owner == nil
			owner = NOBODY
		end
		# figure out permissions
		dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", grouping])
		if dgroup != nil
			if dgroup.default_read_permissions != nil
				read_perms = YAML::load(dgroup.default_read_permissions)
			else
				read_perms = DEFAULT_READ_PERMISSIONS
			end
			if dgroup.default_write_permissions != nil
				write_perms = YAML::load(dgroup.default_write_permissions)
			else
				write_perms = DEFAULT_WRITE_PERMISSIONS
			end
		else
			read_perms = DEFAULT_READ_PERMISSIONS
			write_perms = DEFAULT_WRITE_PERMISSIONS
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
		case valueType
			when :string, "string"
				dataObj.stringdata = dataValue
			when :integer, "integer"
				dataObj.integerdata = dataValue
			when :object, "object"
				dataObj.integerdata = dataValue.to_yaml
			else
				raise ArgumentError
		end
		dataObj.read_permissions = read_perms.to_yaml
		dataObj.write_permissions = write_perms.to_yaml
		dataObj.save!
		
		return dataObj.dataid
	end

	# Modifies a data item of the type and ID
	# specified. Type can be :string, :integer,
	# or :object
	def self.modifyDataItem(dataID, dataType, data)
		dataObj = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if dataObj != nil
			case dataType
				when :string, "string"
					dataObj.stringdata = data
				when :integer, "integer"
					dataObj.integerdata = data
				when :object, "object"
					dataObj.objectdata = data.to_yaml
				else
					return false
			end
			dataObj.save!
			return true
		else
			return false
		end
	end	
	
	# Deletes a data item specified by its ID
	def self.deleteDataItem(dataID)
		dataObj = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if dataObj != nil
			dataObj.destroy
			return true
		else
			return false
		end		
	end
	
	# Deletes a data group specified by its groupID
	def self.deleteDataGroup(groupID)
		dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", groupID])
		if dgroup != nil
			dgroup.destroy
			return true
		else
			return false
		end
	end
	
	# Returns true if a data item exists, false if not.
	def self.doesDataItemExist?(dataID)
		dataObj = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if dataObj != nil
			return true
		else
			return false
		end
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
		return groupingID
	end
	
	# Gets a group of data and returns an array containing all of the data.
	# To only get a certain type of data in the group, you can specify
	# type. You can also specify the order (by creation time) to
	# return them. :desc is newest first, :asc is oldest first. Default
	# is :desc.
	def self.getDataGroupItems(groupingID, type = nil, order = :desc)
		return DataItem.findDataByGrouping(groupingID, type, order)
	end
	
	# Finds a data grouping.
	#
	# +searchBy+ may be :type, :parent, :creator, or :owner,
	# and +query+ is the particular parent, creator, or
	# owner you wish to look for. If you're looking by
	# type only, query should be nil. resultsToReturn is
	# optional, and defaults to returning all results (:all).
	# The other option is to return the first result (:first).
	def self.findDataGrouping(type, searchBy, query, resultsToReturn = :all)
		if resultsToReturn != :all && resultsToReturn != :first
			resultsToReturn = :all
		end
		case searchBy
			when :parent, "parent"
				data = DataGroup.findGroupingsByParent(type, query, resultsToReturn)
				return data
			when :creator, "creator"
				data = DataGroup.findGroupingsByCreator(type, query, resultsToReturn)
				return data
			when :owner, "owner"
				data = DataGroup.findGroupingsByOwner(type, query, resultsToReturn)
				return data
			when :type, "type"
				data = DataGroup.findGroupings(type, resultsToReturn)
				return data
			else
				return nil
		end
	end
	
	# Gets the metadata associated with a particular data
	# grouping, in a hash. The data that is returned should
	# look like this:
	#
	#  { :type => "UUID", :creator => "UUID", :owner => "UUID", :tags => "geek, tech blog, programmer", :title => "Ziggy's Blog!", :description => "Bloggity Blog." }
	#
	# Functions will be provided in the future to lookup UUIDs
	# so types, creators, and owners can be converted into
	# English.
	def self.getDataGroupMetadata(groupingID)
		dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", groupingID])
		if dgroup != nil
			h = { :type => dgroup.groupingtype, :creator => dgroup.creator, :owner => dgroup.owner, :tags => dgroup.tags, :title => dgroup.title, :description => dgroup.description }
			return h
		else
			return nil
		end
	end
	
	# Modifies the metadata for the specified data group.
	# Valid metadata names are: :type, :creator, :owner,
	# :tags, :title, and :description
	def self.modifyDataGroupMetadata(groupID, name, value)
		dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", groupID])
		if dgroup != nil
			case name
				when :type, "type"
					dgroup.groupingtype = value
				when :creator, "creator"
					dgroup.creator = value
				when :owner, "owner"
					dgroup.owner = value
				when :tags, "tags"
					dgroup.tags = value
				when :title, "title"
					dgroup.title = value
				when :description, "description"
					dgroup.description = value
				else
					return false
			end
			dgroup.save!
			return true
		else
			return false
		end
	end	
	
	# Gets the metadata associated with a particular data
	# item, in a hash. The data that is returned should
	# look like this:
	# 
	#  { :type => "UUID", :creator => "UUID", :owner => "UUID", :tags => "stupid, retarded, excellent", :title => "Ten Reasons Coke Sucks", :description => "Ten reasons why I hate Coke", :datacreator => "UUID", :creation => unix_timestamp }
	#
	# Functions will be provided in the future to lookup UUIDs
	# so that this kind of thing can be looked up.
	def self.getDataItemMetadata(dataID)
		ditem = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if ditem != nil
			h = { :type => ditem.datatype, :creator => ditem.creator, :owner => ditem.owner, :tags => ditem.tags, :creation => ditem.creation, :title => ditem.title, :description => ditem.description, :datacreator => ditem.datacreator }
			return h
		else
			return nil
		end
	end
	
	# Modifies the data item metadata specified in name.
	# Name may be :type, :creator, :owner, :tags, :title,
	# :datacreator, or :description.
	def self.modifyDataItemMetadata(dataID, name, value)
		dataObj = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if dataObj != nil
			case name
				when :type, "type"
					dataObj.datatype = value
				when :creator, "creator"
					dataObj.creator = value
				when :owner, "owner"
					dataObj.owner = value
				when :tags, "tags"
					dataObj.tags = value
				when :title, "title"
					dataObj.title = value
				when :datacreator, "datacreator"
					dataObj.datacreator = value
				when :description, "description"
					dataObj.description = value
				else
					return false
			end
			dataObj.save!
			return true
		else
			return false
		end
	end
	
	# Sets the permissions on a data item. +kind+
	# is either :read or :write for read permissions
	# and write permissions respectively. +value+
	# is the permission array (see Services:UserService
	# on the wiki)
	def self.setPermissions(dataID, kind, value)
		ditem = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if ditem != nil
			case kind
				when :write, "write"
					ditem.write_permissions = value.to_yaml
					ditem.save!
					return true
				when :read, "read"
					ditem.read_permissions = value.to_yaml
					ditem.save!
					return true
				else
					return false
			end
		else
			return false
		end
	end
	
	# Returns an array containing the permissions requested
	# of the data item specified.
	def self.getPermissions(dataID, kind)
		ditem = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if ditem != nil
			case kind
				when :write, "write"
					p = YAML::load(ditem.write_permissions)
					return p
				when :read, "read"
					p = YAML::load(ditem.read_permissions)
					return p
				else
					return nil
			end
		else
			return nil
		end	
	end
	
	# Sets the default permissions on a data group.
	# See setPermissions for more info.
	def self.setDefaultPermissions(groupID, kind, value)
		dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", groupID])
		if dgroup != nil
			case kind
				when :write, "write"
					dgroup.default_write_permissions = value.to_yaml
					dgroup.save!
					return true
				when :read, "read"
					dgroup.default_read_permissions = value.to_yaml
					dgroup.save!
					return true
				else
					return false
			end
		else
			return false
		end	
	end
	
	# Returns true if the user specified (by UUID) can
	# read the data item or data group specified (by UUID)
	def self.canRead?(dataID, userID)
		ditem = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if ditem != nil
			# the creator and owner always have permission to read/write.
			if ditem.creator == userID
				return true
			elsif ditem.owner == userID
				return true
			else
				return UserService.checkPermissions(YAML::load(ditem.read_permissions), userID)
			end
		else
			# check data group
			dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", dataID])
			if dgroup != nil
				if dgroup.creator == userID
					return true
				elsif dgroup.owner == userID
					return true
				else
					return UserService.checkPermissions(YAML::load(dgroup.default_read_permissions), userID)
				end
			else
				return false
			end		
		end
	end
	
	# Returns true if the user specified (by UUID) can
	# write to the data item or data group specified (by UUID)
	def self.canWrite?(dataID, userID)
		ditem = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if ditem != nil
			# the creator and owner always have permission to read/write.
			if ditem.creator == userID
				return true
			elsif ditem.owner == userID
				return true
			else
				return UserService.checkPermissions(YAML::load(ditem.write_permissions), userID)
			end
		else
			# check data group
			dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", dataID])
			if dgroup != nil
				if dgroup.creator == userID
					return true
				elsif dgroup.owner == userID
					return true
				else
					return UserService.checkPermissions(YAML::load(dgroup.default_write_permissions), userID)
				end
			else
				return false
			end
		end
	end
end

Services.registerService(DataService)