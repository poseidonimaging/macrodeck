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
	
	# *NOTICE* This function is temporary only!
	def self.lookupUUID(id)
		case id
			when DataService.serviceUUID then		return DataService.serviceName
			when BlogService.serviceUUID then		return BlogService.serviceName
			when UUIDService.serviceUUID then		return UUIDService.serviceName
			when USER_CSAKON then					return "csakon"
			when USER_ZIGGYTHEHAMSTER then			return "ziggythehamster"
		end
	end
end

# Register this service with Services.
Services.registerService(UUIDService)