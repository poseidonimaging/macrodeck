# This service requires DataService to work.
# It provides some functions to work with profiles.

require "profile"       # profile virtual model
require "profile_item"  # profile item virtual model

def ProfileService < BaseService
  	@serviceAuthor = "Eugene Hlyzov <ehlyzov@issart.com>"
	@serviceID = "com.macrodeck.ProfileService"
	@serviceName = "ProfileService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 1	
    @serviceUUID = "c38837a2-25dc-4ba3-8b7d-4c3a6afa828c"
    # Creates a new profile. You should use createProfileItem to add 
    # some data here. Parameter's format is {:owner => "...", etc.}
    def self.createProfile(metadata)
        return DataService.createDataGrouping(DGROUP_PROFILE, nil, nil, metadata)
    end
    
    # Deletes profile by its profileId. 
    # *NOTE*! This method also removes all profile items which have 
    # this profileId as parent. 
    def self.deleteProfile(profile_id)
        if Profile.exist?(profile_id)
            items = DataService.getDataGroupItems(profile_id, nil)
            items.each { |item|
                DataService.deleteDataItem(item.dataid)
            }
            return DataService.deleteDataGroup(profile_id)
         else
            return false
         end
    end
    
    # Modifies the metadata for the specified profile.
    def self.modifyProfileMetadata(profile_id, name, value)
        if DataService.doesDataGroupExist?(profileID)
            return DataService.modifyDataGroupMetadata(profile_id,name,value)
        else
            return false
        end
    end
    
    # Creates a new profile's item within given profile.
    def self.addProfileItem(profile_id, item_type, item_value, item_metadata)
		profile_meta = DataService.getDataGroupMetadata(profile_id)
		item_metadata.update(
		  {
		    :owner => profile_meta[:owner],
		    :creatorapp => @serviceUUID,
		    :grouping => profile_id		    
          })
		item_id = DataService.createData(DTYPE_PROFILE_FIELD, item_type, item_value, item_metadata)
		return item_id
    end
    
    # Deletes a specified profile field.
    # 
    def self.deleteProfileItem(item_id)
        return DataService.deleteDataItem(item_id)
    end
    
    # Modifies a profile field type and value.
    # 
    def self.modifyProfileItem(item_id, item_type, item_value)
        if DataService.doesDataItemExist?(item_id)
            DataService.modifyDataItem(item_id, item_type, item_value)
            item_meta.each { |name,value|
                DataService.modifyDataItemMetadata(item_id, name, value)            
            }
        else
            return false                
        end
    end

    # Modifies a profile field metadata.
    # 
    def self.modifyProfileItem(item_id, metadata)
        if DataService.doesDataItemExist?(item_id)
            metadata.each { |name,value|
                DataService.modifyDataItemMetadata(item_id, name, value)            
            }
        else
            return false                
        end
    end
    
    # Returns a list of all fileds of specified profile
    #
    def self.getProfileItems(profile_id)
        if Profile.exist?(profile_id) 
            return DataService.getDataGroupItems(profile_id, nil)    
        else
            return false
        end   
    end

end
