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
	
	class YAML < ActionWebService::Struct
		member :yamlContent,	:string
	end
end

# The DataService API definition
class DataServiceAPI < ActionWebService::API::Base
	api_method :create_data_item, {
			:expects =>	[{ :authCode	=> :string },
						 { :grouping	=> :string },
						 { :metadata	=> DataServiceCustomTypes::ItemMetadata }],
			:returns => [:string]
		}
	api_method :delete_data_item, {
			:expects =>	[{ :authCode	=> :string },
						 { :itemUUID	=> :string }],
			:returns => [:bool]
		}
	api_method :set_string_value, {
			:expects =>	[{ :authCode	=> :string },
						 { :itemUUID	=> :string },
						 { :value		=> :string }],
			:returns => [:bool]
		}
	api_method :delete_string_value, {
			:expects => [{ :authCode	=> :string },
						 { :itemUUID	=> :string }],
			:returns =>	[:bool]
		}
	api_method :set_integer_value, {
			:expects =>	[{ :authCode	=> :string },
						 { :itemUUID	=> :string },
						 { :value		=> :int }],
			:returns => [:bool]
		}
	api_method :delete_integer_value, {
			:expects => [{ :authCode	=> :string },
						 { :itemUUID	=> :string }],
			:returns =>	[:bool]
		}
	api_method :set_object_value, {
			:expects =>	[{ :authCode	=> :string },
						 { :itemUUID	=> :string },
						 { :value		=> DataServiceCustomTypes::YAML }],
			:returns => [:bool]
		}
	api_method :delete_object_value, {
			:expects => [{ :authCode	=> :string },
						 { :itemUUID	=> :string }],
			:returns =>	[:bool]
		}
end

# The Data Web Service. Provides SOAP/XML-RPC for DataService.
# The user's authCode must be specified in every function that
# requires it. In MacroDeck, we'll provide widgets with the
# authCode via a JavaScript variable (probably something like
# CurrentUser.authCode). In your app, you will probably need to
# provide the user with a copy-and-pastable authCode if you want
# to be able to use these APIs.
class DataWebService < ActionWebService::Base
	web_service_api DataServiceAPI
	
	# Creates a data item but does not populate it with data.
	# A grouping for the data must exist. Returns the UUID
	# of the data item or nil/null if failure.
	def create_data_item(authCode, grouping, metadata)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			# The user exists! Hooray!
			# Now we check to make sure they have permission to write to this grouping.
			if DataService.canWrite?(grouping, user.uuid)
				# They can write, create the data!
				group_md = DataService.getDataGroupMetadata(grouping)
				if metadata[:title] == ""
					title = nil
				else
					title = metadata[:title]
				end
				if metadata[:description] == ""
					description = nil
				else
					description = metadata[:description]
				end
				if metadata[:creatorApp] == ""
					creatorapp = nil
				else
					creatorapp = metadata[:creatorApp]
				end
				uuid = DataService.createData(metadata[:dataType], :nothing, nil, { :creator => user.uuid, :owner => group_md[:owner], :title => title, :description => description, :creatorapp => creatorapp, :grouping => grouping })
				return uuid
			else
				return nil
			end
		else
			return nil
		end
	end
	
	# Deletes a data item and all associated data and
	# metadata.
	def delete_data_item(authCode, itemUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.deleteDataItem(itemUUID)
				return result
			else
				return false
			end
		else
			return false
		end	
	end
	
	# Sets a string value on an existing data item. Returns
	# true if all is okay otherwise false.
	def set_string_value(authCode, itemUUID, value)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :string, value)
				return result
			else
				return false
			end
		else
			return false
		end	
	end
	
	# Deletes the string value of a data item. Returns true
	# if all is good, otherwise false.
	def delete_string_value(authCode, itemUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :string, nil)
				return result
			else
				return false
			end
		else
			return false
		end		
	end
	
	# Sets an integer value on an existing data item. Returns
	# true if all is okay otherwise false.
	def set_integer_value(authCode, itemUUID, value)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :integer, value)
				return result
			else
				return false
			end
		else
			return false
		end	
	end
	
	# Deletes the integer value of a data item. Returns true
	# if all is good, otherwise false.
	def delete_integer_value(authCode, itemUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :integer, nil)
				return result
			else
				return false
			end
		else
			return false
		end		
	end
	
	# Sets an object value on an existing data item. Returns
	# true if all is okay otherwise false. Expects the object
	# to be specified as YAML.
	def set_object_value(authCode, itemUUID, value)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				# This will load the YAML into an object so that
				# partially malformed YAML is inserted correctly.
				obj = YAML::load(value[:yamlContent])
				result = DataService.modifyDataItem(itemUUID, :object, obj)
				return result
			else
				return false
			end
		else
			return false
		end	
	end
	
	# Deletes the object value of a data item. Returns true
	# if all is good, otherwise false.
	def delete_object_value(authCode, itemUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :object, nil)
				return result
			else
				return false
			end
		else
			return false
		end		
	end	
end