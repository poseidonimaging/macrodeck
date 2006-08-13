# The DataWebService. Provides DataService functions to
# remote via ActionWebService.

# Structs for DataWebService.
module DataServiceCustomTypes
	class ItemMetadata < ActionWebService::Struct
		# creator and owner are inferred by the current user and parent group/item
		member :dataType,		:string
		member :title,			:string
		member :description,	:string
		member :creatorApp,		:string
	end
end

# The DataService API definition
class DataServiceAPI < ActionWebService::API::Base
	api_method :create_data_item,
		:expects =>	[{ :grouping	=> :string },
					 { :metadata	=> DataServiceCustomTypes::ItemMetadata }],
		:returns => [:string]
	api_method :set_string_value,
		:expects =>	[{ :itemUUID	=> :string },
					 { :value		=> :string }],
		:returns => [:bool]
	api_method :delete_string_value,
		:expects => [{ :itemUUID	=> :string }],
		:returns =>	[:bool]
end

# The Data Web Service
class DataWebService < ActionWebService::Base
	web_service_api DataServiceAPI
	
	# Create a data item but does not populate it with data.
	# A grouping for the data must exist. Returns the UUID
	# of the data item.
	def create_data_item(grouping, metadata)
	
	end
	
	# Sets a string value on an existing data item. Returns
	# true if all is okay otherwise false.
	def set_string_value(itemUUID, value)
	
	end
	
	# Deletes the string value of a data item. Returns true
	# if all is good, otherwise false.
	def delete_string_value(itemUUID)
	
	end
end