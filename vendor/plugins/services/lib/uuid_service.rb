# This service generates UUIDs for other services.
# It uses the Ruby Gem "uuidtools".

require_gem "uuidtools", ">= 1.0.0"

class UUIDService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.UUIDService"
	@serviceName = "UUIDService"	
	@serviceVersionMajor = 1
	@serviceVersionMinor = 0	
	@serviceVersionRevision = 20060624
	@serviceUUID = "05705b50-135a-489f-bbbd-a8fc7d38b643"
	
	# Returns a string containing a random UUID.
	def self.generateUUID()
		return UUID.random_create.to_s
	end
	
	# Looks up the uuid and returns a human readable
	# name. This searches users, groups, services, and
	# so on. *NOTE* It doesn't _actually_ look services
	# or anything other than users up yet.
	def self.lookupUUID(uuid)
		displayname = UserService.lookupUUID(uuid)
		if displayname != nil
			return displayname
		else
			return uuid
		end
	end
end

# Register this service with Services.
Services.registerService(UUIDService)